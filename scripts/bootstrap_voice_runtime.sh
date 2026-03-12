#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="${VOITRAN_RUNTIME_ROOT:-/Volumes/SSDExterno/Voitran_runtime}"
SIDECAR_DIR="${RUNTIME_DIR}/voice_sidecar"
VENV_DIR="${SIDECAR_DIR}/.venv"

mkdir -p \
  "${RUNTIME_DIR}/models" \
  "${RUNTIME_DIR}/caches" \
  "${RUNTIME_DIR}/voices/samples" \
  "${RUNTIME_DIR}/voices/consents" \
  "${RUNTIME_DIR}/voices/profiles" \
  "${RUNTIME_DIR}/voices/outputs" \
  "${RUNTIME_DIR}/logs/voice-sidecar"

python3 -m venv "${VENV_DIR}"
"${VENV_DIR}/bin/pip" install --upgrade pip >/dev/null
"${VENV_DIR}/bin/pip" install -r "${ROOT_DIR}/scripts/voice_sidecar_requirements.txt"

cat <<EOF
[voice_runtime] runtime pronto
[voice_runtime] root=${RUNTIME_DIR}
[voice_runtime] venv=${VENV_DIR}
EOF
