#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import math
import os
import shutil
import subprocess
import sys
import time
import uuid
import wave
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any


RUNTIME_ROOT = Path(os.environ.get("VOITRAN_RUNTIME_ROOT", "/Volumes/SSDExterno/Voitran_runtime"))
VOICES_ROOT = RUNTIME_ROOT / "voices"
SAMPLES_ROOT = VOICES_ROOT / "samples"
CONSENTS_ROOT = VOICES_ROOT / "consents"
PROFILES_ROOT = VOICES_ROOT / "profiles"
OUTPUTS_ROOT = VOICES_ROOT / "outputs"
LOGS_ROOT = RUNTIME_ROOT / "logs" / "voice-sidecar"
MODELS_ROOT = RUNTIME_ROOT / "models"


@dataclass
class RuntimeContext:
    runtime_root: Path = RUNTIME_ROOT
    samples_root: Path = SAMPLES_ROOT
    consents_root: Path = CONSENTS_ROOT
    profiles_root: Path = PROFILES_ROOT
    outputs_root: Path = OUTPUTS_ROOT
    logs_root: Path = LOGS_ROOT
    models_root: Path = MODELS_ROOT

    def ensure_layout(self) -> None:
        for path in (
            self.runtime_root,
            self.samples_root,
            self.consents_root,
            self.profiles_root,
            self.outputs_root,
            self.logs_root,
            self.models_root,
        ):
            path.mkdir(parents=True, exist_ok=True)


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def iso(value: datetime) -> str:
    return value.replace(microsecond=0).isoformat().replace("+00:00", "Z")


def module_available(name: str) -> bool:
    return importlib.util.find_spec(name) is not None


def read_payload() -> dict[str, Any]:
    raw = sys.stdin.read().strip()
    if not raw:
        return {}
    return json.loads(raw)


def write_payload(payload: dict[str, Any]) -> None:
    json.dump(payload, sys.stdout, ensure_ascii=True)


def json_error(message: str, code: int = 1) -> int:
    json.dump({"error": message}, sys.stderr, ensure_ascii=True)
    sys.stderr.write("\n")
    return code


def collect_model_hints(context: RuntimeContext) -> list[str]:
    if not context.models_root.exists():
        return []

    hints: list[str] = []
    for child in sorted(context.models_root.iterdir()):
        if child.is_dir():
            hints.append(child.name)
        elif child.suffix in {".pth", ".pt", ".onnx"}:
            hints.append(child.name)
    return hints


def preferred_engine() -> tuple[str, list[str], list[str]]:
    engines: list[str] = []
    warnings: list[str] = []

    if module_available("openvoice"):
        engines.append("openvoice-v2")
    else:
        warnings.append("openvoice-v2 ausente no runtime local")

    if module_available("silero_vad"):
        engines.append("silero-vad")
    else:
        warnings.append("silero-vad ausente; fallback de energia sera usado")

    if shutil.which("say"):
        engines.append("system-say-fallback")
    else:
        warnings.append("comando 'say' indisponivel no macOS atual")

    preferred = "openvoice-v2" if "openvoice-v2" in engines else (engines[0] if engines else "unavailable")
    return preferred, engines, warnings


def runtime_health(context: RuntimeContext) -> dict[str, Any]:
    context.ensure_layout()
    preferred, engines, warnings = preferred_engine()
    models = collect_model_hints(context)
    ready = bool(engines) and context.runtime_root.exists()

    return {
        "status": "ok" if ready else "degraded",
        "runtimeRoot": str(context.runtime_root),
        "ready": ready,
        "preferredEngine": preferred,
        "availableEngines": engines,
        "modelsFound": models,
        "warnings": warnings,
    }


def read_wave_metrics(path: Path) -> dict[str, float]:
    with wave.open(str(path), "rb") as handle:
        frames = handle.readframes(handle.getnframes())
        sample_width = handle.getsampwidth()
        frame_rate = handle.getframerate()
        channels = handle.getnchannels()
        duration = handle.getnframes() / float(frame_rate or 1)

    if sample_width != 2:
        return {
            "duration_seconds": duration,
            "peak": 0.0,
            "rms": 0.0,
            "clipping_ratio": 0.0,
        }

    import array

    samples = array.array("h", frames)
    if channels > 1:
        mono = samples[::channels]
    else:
        mono = samples

    if not mono:
        return {
            "duration_seconds": duration,
            "peak": 0.0,
            "rms": 0.0,
            "clipping_ratio": 0.0,
        }

    peak = max(abs(value) for value in mono) / 32767.0
    rms = math.sqrt(sum((value / 32767.0) ** 2 for value in mono) / len(mono))
    clipping = sum(1 for value in mono if abs(value) >= 32000) / len(mono)
    return {
        "duration_seconds": duration,
        "peak": peak,
        "rms": rms,
        "clipping_ratio": clipping,
    }


def sample_hash(paths: list[Path]) -> str:
    digest = hashlib.sha256()
    for path in paths:
        digest.update(path.read_bytes())
    return digest.hexdigest()


def voice_profile_payload(profile_path: Path) -> dict[str, Any]:
    return json.loads(profile_path.read_text(encoding="utf-8"))


def choose_system_voice(locale: str) -> str:
    if locale.startswith("pt"):
        return "Luciana"
    if locale.startswith("en"):
        return "Samantha"
    return "Samantha"


def synthesize_with_system_say(text: str, locale: str, output_path: Path) -> tuple[str, list[str]]:
    voice = choose_system_voice(locale)
    command = ["say", "-v", voice, "-o", str(output_path), text]
    subprocess.run(command, check=True, capture_output=True)
    return "system-say-fallback", ["openvoice-v2 indisponivel; usando sintese local do macOS sem clonagem real"]


def command_health(context: RuntimeContext) -> dict[str, Any]:
    return runtime_health(context)


def command_enroll(context: RuntimeContext, payload: dict[str, Any]) -> dict[str, Any]:
    context.ensure_layout()
    started = time.perf_counter()

    sample_paths = [Path(path) for path in payload.get("sample_paths", [])]
    if not sample_paths:
        raise ValueError("sample_paths e obrigatorio")
    if len(sample_paths) < 3:
        raise ValueError("grave ao menos 3 frases antes do enroll")

    missing = [path for path in sample_paths if not path.exists()]
    if missing:
        raise ValueError(f"amostras ausentes: {', '.join(str(path) for path in missing)}")

    consent_manifest_path = Path(payload["consent_manifest_path"])
    if not consent_manifest_path.exists():
        raise ValueError("consent_manifest_path invalido")

    metrics = [read_wave_metrics(path) for path in sample_paths]
    total_duration = sum(item["duration_seconds"] for item in metrics)
    warnings: list[str] = []

    if total_duration < 10:
        raise ValueError("duracao util insuficiente; grave ao menos 10 segundos")
    if any(item["clipping_ratio"] > 0.02 for item in metrics):
        warnings.append("algumas amostras apresentam clipping acima do ideal")
    if any(item["rms"] < 0.015 for item in metrics):
        warnings.append("algumas amostras estao com volume muito baixo")

    profile_id = f"voice-profile-{uuid.uuid4().hex[:12]}"
    profile_dir = context.profiles_root / profile_id
    profile_dir.mkdir(parents=True, exist_ok=True)
    expires_at = utc_now() + timedelta(days=180)
    preferred, _, engine_warnings = preferred_engine()
    warnings.extend(engine_warnings)

    profile = {
        "id": profile_id,
        "ownerLocalID": payload.get("owner_local_id", "mac-local"),
        "locale": payload.get("locale", "pt-BR"),
        "approvedLocales": payload.get("approved_locales", ["pt-BR", "en"]),
        "createdAt": iso(utc_now()),
        "expiresAt": iso(expires_at),
        "consentManifestPath": str(consent_manifest_path),
        "samplePaths": [str(path) for path in sample_paths],
        "status": "ready",
        "engine": preferred,
        "warnings": warnings,
        "sampleHash": sample_hash(sample_paths),
    }

    (profile_dir / "profile.json").write_text(json.dumps(profile, ensure_ascii=True, indent=2), encoding="utf-8")
    latency_ms = int((time.perf_counter() - started) * 1000)
    return {
        "voiceProfile": {
            key: value for key, value in profile.items() if key != "sampleHash"
        },
        "totalDurationSeconds": round(total_duration, 2),
        "latencyMilliseconds": latency_ms,
        "warnings": warnings,
    }


def command_list_profiles(context: RuntimeContext) -> dict[str, Any]:
    context.ensure_layout()
    profiles: list[dict[str, Any]] = []
    if context.profiles_root.exists():
        for profile_path in sorted(context.profiles_root.glob("*/profile.json")):
            profiles.append(voice_profile_payload(profile_path))
    return {"profiles": profiles}


def command_inspect_profile(context: RuntimeContext, payload: dict[str, Any]) -> dict[str, Any]:
    profile_id = payload.get("voice_profile_id")
    if not profile_id:
        raise ValueError("voice_profile_id e obrigatorio")
    profile_path = context.profiles_root / profile_id / "profile.json"
    if not profile_path.exists():
        raise ValueError("perfil vocal nao encontrado")
    return {"voiceProfile": voice_profile_payload(profile_path)}


def command_revoke_profile(context: RuntimeContext, payload: dict[str, Any]) -> dict[str, Any]:
    profile_id = payload.get("voice_profile_id")
    if not profile_id:
        raise ValueError("voice_profile_id e obrigatorio")
    profile_dir = context.profiles_root / profile_id
    if profile_dir.exists():
        shutil.rmtree(profile_dir)
    return {"revoked": True, "voice_profile_id": profile_id}


def command_synthesize(context: RuntimeContext, payload: dict[str, Any]) -> dict[str, Any]:
    context.ensure_layout()
    started = time.perf_counter()
    text = payload.get("text", "").strip()
    profile_id = payload.get("voice_profile_id")
    locale = payload.get("locale", "pt-BR")

    if not text:
        raise ValueError("texto vazio para sintese")
    if not profile_id:
        raise ValueError("voice_profile_id e obrigatorio")

    profile_path = context.profiles_root / profile_id / "profile.json"
    if not profile_path.exists():
        raise ValueError("perfil vocal nao encontrado")
    profile = voice_profile_payload(profile_path)

    if locale not in profile.get("approvedLocales", []):
        raise ValueError("locale solicitado nao esta aprovado para este perfil")

    expires_at = datetime.fromisoformat(profile["expiresAt"].replace("Z", "+00:00"))
    if expires_at < utc_now():
        raise ValueError("perfil vocal expirado")

    consent_path = Path(profile["consentManifestPath"])
    if not consent_path.exists():
        raise ValueError("consentimento local ausente para este perfil")

    output_path = context.outputs_root / f"{profile_id}-{uuid.uuid4().hex[:8]}.aiff"
    engine, warnings = synthesize_with_system_say(text=text, locale=locale, output_path=output_path)
    latency_ms = int((time.perf_counter() - started) * 1000)

    return {
        "voiceProfileID": profile_id,
        "locale": locale,
        "outputAudioPath": str(output_path),
        "latencyMilliseconds": latency_ms,
        "engine": engine,
        "warnings": warnings,
    }


COMMANDS = {
    "health": command_health,
    "enroll": command_enroll,
    "list-profiles": command_list_profiles,
    "inspect-profile": command_inspect_profile,
    "revoke-profile": command_revoke_profile,
    "synthesize": command_synthesize,
}


def main() -> int:
    parser = argparse.ArgumentParser(description="Voitran voice sidecar")
    parser.add_argument("command", choices=sorted(COMMANDS))
    args = parser.parse_args()

    payload = read_payload()
    context = RuntimeContext()

    try:
        result = COMMANDS[args.command](context, payload) if args.command not in {"health", "list-profiles"} else COMMANDS[args.command](context)  # type: ignore[misc]
    except Exception as exc:  # pragma: no cover - CLI surface
        return json_error(str(exc))

    write_payload(result)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
