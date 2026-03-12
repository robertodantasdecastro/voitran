#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
import os
import subprocess
import sys
import uuid
import wave
from datetime import datetime, timedelta, timezone
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
RUNTIME_ROOT = Path(os.environ.get("VOITRAN_RUNTIME_ROOT", "/Volumes/SSDExterno/Voitran_runtime"))
VOICE_RUNTIME_SCRIPT = SCRIPT_DIR / "voice_runtime.sh"
SAMPLES_ROOT = RUNTIME_ROOT / "voices" / "samples"
CONSENTS_ROOT = RUNTIME_ROOT / "voices" / "consents"
VOICE_LAB_LOGS_ROOT = RUNTIME_ROOT / "logs" / "voice-lab"

GUIDED_PHRASES = [
    ("ptbr-01", "pt-BR"),
    ("ptbr-02", "pt-BR"),
    ("ptbr-03", "pt-BR"),
    ("en-01", "en"),
]


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def iso(value: datetime) -> str:
    return value.replace(microsecond=0).isoformat().replace("+00:00", "Z")


def valid_wav_files() -> list[Path]:
    if not SAMPLES_ROOT.exists():
        return []
    return [
        path for path in sorted(SAMPLES_ROOT.glob("*.wav"), key=lambda item: item.stat().st_mtime, reverse=True)
        if path.is_file() and not path.name.startswith("._")
    ]


def duration_for(path: Path) -> float:
    with wave.open(str(path), "rb") as handle:
        return handle.getnframes() / float(handle.getframerate() or 1)


def latest_samples_summary() -> dict:
    samples = []
    warnings: list[str] = []

    files = valid_wav_files()
    for phrase_id, locale in GUIDED_PHRASES:
        candidates = [path for path in files if path.name.startswith(f"{phrase_id}-")]
        if not candidates:
            warnings.append(f"amostra ausente para {phrase_id}")
            continue

        latest = candidates[0]
        samples.append(
            {
                "phraseID": phrase_id,
                "locale": locale,
                "path": str(latest),
                "durationSeconds": round(duration_for(latest), 3),
                "modifiedAt": iso(datetime.fromtimestamp(latest.stat().st_mtime, tz=timezone.utc)),
            }
        )

    total_duration = round(sum(item["durationSeconds"] for item in samples), 3)
    ready = len(samples) >= 3 and total_duration >= 10
    return {
        "samples": samples,
        "totalDurationSeconds": total_duration,
        "ready": ready,
        "warnings": warnings,
    }


def run_voice_runtime(command: str, payload: dict | None = None) -> dict:
    process = subprocess.run(
        ["/bin/bash", str(VOICE_RUNTIME_SCRIPT), command],
        input=json.dumps(payload or {}).encode("utf-8"),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )

    if process.returncode != 0:
        message = process.stderr.decode("utf-8").strip() or process.stdout.decode("utf-8").strip()
        raise RuntimeError(message)

    return json.loads(process.stdout.decode("utf-8"))


def create_consent_manifest(sample_paths: list[str], approved_locales: list[str], owner_local_id: str) -> Path:
    CONSENTS_ROOT.mkdir(parents=True, exist_ok=True)

    digest = hashlib.sha256()
    for sample_path in sample_paths:
        digest.update(Path(sample_path).read_bytes())

    voice_identity_id = f"voice-lab-{uuid.uuid4().hex[:12]}"
    expires_at = utc_now() + timedelta(days=180)
    manifest = {
        "voiceIdentityID": voice_identity_id,
        "owner": owner_local_id,
        "source": "voice-lab-automation",
        "scope": "local-voice-cloning-and-preview",
        "expiresAt": iso(expires_at),
        "approvedLocales": approved_locales,
        "hash": digest.hexdigest(),
        "revocationPolicy": "user-revocable-local-delete",
    }

    output = CONSENTS_ROOT / f"{voice_identity_id}.json"
    output.write_text(json.dumps(manifest, ensure_ascii=True, indent=2), encoding="utf-8")
    return output


def command_health(_: argparse.Namespace) -> dict:
    return run_voice_runtime("health")


def command_latest_samples(_: argparse.Namespace) -> dict:
    return latest_samples_summary()


def command_train_latest(args: argparse.Namespace) -> dict:
    summary = latest_samples_summary()
    if not summary["ready"]:
        raise RuntimeError(json.dumps(summary, ensure_ascii=True))

    sample_paths = [item["path"] for item in summary["samples"]]
    consent_path = create_consent_manifest(sample_paths, [args.source_locale, args.target_locale], args.owner_local_id)
    enrollment = run_voice_runtime(
        "enroll",
        {
            "owner_local_id": args.owner_local_id,
            "locale": args.source_locale,
            "approved_locales": [args.source_locale, args.target_locale],
            "sample_paths": sample_paths,
            "consent_manifest_path": str(consent_path),
        },
    )

    return {
        "status": "ok",
        "sampleSummary": summary,
        "enrollment": enrollment,
        "consentManifestPath": str(consent_path),
    }


def command_smoke(args: argparse.Namespace) -> dict:
    health = run_voice_runtime("health")
    train_result = command_train_latest(args)
    voice_profile_id = train_result["enrollment"]["voiceProfile"]["id"]
    synthesis = run_voice_runtime(
        "synthesize",
        {
            "text": args.text,
            "voice_profile_id": voice_profile_id,
            "locale": args.target_locale,
        },
    )

    VOICE_LAB_LOGS_ROOT.mkdir(parents=True, exist_ok=True)
    report_path = VOICE_LAB_LOGS_ROOT / f"smoke-{datetime.now().strftime('%Y%m%d-%H%M%S')}.json"
    report = {
        "status": "ok",
        "health": health,
        "sampleSummary": train_result["sampleSummary"],
        "enrollment": train_result["enrollment"],
        "synthesis": synthesis,
        "reportPath": str(report_path),
    }
    report_path.write_text(json.dumps(report, ensure_ascii=True, indent=2), encoding="utf-8")
    return report


def main() -> int:
    parser = argparse.ArgumentParser(description="Voice Lab automation helpers")
    parser.add_argument("command", choices=["health", "latest-samples", "train-latest", "smoke"])
    parser.add_argument("--owner-local-id", default="voitran-automation")
    parser.add_argument("--source-locale", default="pt-BR")
    parser.add_argument("--target-locale", default="en")
    parser.add_argument("--text", default="This is an operational smoke test for the Voitran Voice Lab.")
    args = parser.parse_args()

    commands = {
        "health": command_health,
        "latest-samples": command_latest_samples,
        "train-latest": command_train_latest,
        "smoke": command_smoke,
    }

    try:
        result = commands[args.command](args)
    except Exception as exc:
        json.dump({"status": "error", "error": str(exc)}, sys.stderr, ensure_ascii=True)
        sys.stderr.write("\n")
        return 1

    json.dump(result, sys.stdout, ensure_ascii=True)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
