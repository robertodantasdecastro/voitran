#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
RUNTIME_DIR="${VOITRAN_RUNTIME_ROOT:-/Volumes/SSDExterno/Voitran_runtime}"
SIDECAR_DIR="${RUNTIME_DIR}/voice_sidecar"
VENV_DIR="${SIDECAR_DIR}/.venv"
REQUIREMENTS_FILE="${SCRIPT_DIR}/voice_sidecar_requirements.txt"
STATE_FILE="${SIDECAR_DIR}/requirements.sha256"

mkdir -p \
  "${RUNTIME_DIR}/models" \
  "${RUNTIME_DIR}/caches" \
  "${RUNTIME_DIR}/voices/samples" \
  "${RUNTIME_DIR}/voices/consents" \
  "${RUNTIME_DIR}/voices/profiles" \
  "${RUNTIME_DIR}/voices/outputs" \
  "${RUNTIME_DIR}/logs/voice-sidecar"

current_hash="$(shasum -a 256 "${REQUIREMENTS_FILE}" | awk '{print $1}')"
stored_hash=""
if [[ -f "${STATE_FILE}" ]]; then
  stored_hash="$(cat "${STATE_FILE}")"
fi

if [[ ! -x "${VENV_DIR}/bin/python3" ]]; then
  python3 -m venv "${VENV_DIR}"
fi

if [[ "${current_hash}" != "${stored_hash}" ]]; then
  "${VENV_DIR}/bin/pip" install --upgrade pip >/dev/null
  "${VENV_DIR}/bin/pip" install -r "${REQUIREMENTS_FILE}"
  printf '%s\n' "${current_hash}" >"${STATE_FILE}"
fi

cat <<EOF
[voice_runtime] runtime pronto
[voice_runtime] root=${RUNTIME_DIR}
[voice_runtime] venv=${VENV_DIR}
EOF
