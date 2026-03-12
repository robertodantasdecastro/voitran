#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="${VOITRAN_RUNTIME_ROOT:-/Volumes/SSDExterno/Voitran_runtime}"
VENV_DIR="${RUNTIME_DIR}/voice_sidecar/.venv"

export VOITRAN_RUNTIME_ROOT="${RUNTIME_DIR}"
export PYTHONPATH="${ROOT_DIR}:${PYTHONPATH:-}"

if [[ -x "${VENV_DIR}/bin/python3" ]]; then
  exec "${VENV_DIR}/bin/python3" "${ROOT_DIR}/scripts/voice_sidecar.py" "$@"
fi

exec python3 "${ROOT_DIR}/scripts/voice_sidecar.py" "$@"
