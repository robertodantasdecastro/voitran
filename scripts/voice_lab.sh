#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
shift || true
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "${mode}" in
  bootstrap)
    bash "${SCRIPT_DIR}/bootstrap_voice_runtime.sh"
    ;;
  health)
    python3 "${SCRIPT_DIR}/voice_lab_automation.py" health "$@"
    ;;
  list-profiles)
    bash "${SCRIPT_DIR}/voice_runtime.sh" list-profiles
    ;;
  latest-samples)
    python3 "${SCRIPT_DIR}/voice_lab_automation.py" latest-samples "$@"
    ;;
  train-latest)
    python3 "${SCRIPT_DIR}/voice_lab_automation.py" train-latest "$@"
    ;;
  ingest)
    python3 "${SCRIPT_DIR}/voice_lab_automation.py" train-latest "$@"
    ;;
  eval)
    python3 "${SCRIPT_DIR}/voice_lab_automation.py" smoke "$@"
    ;;
  smoke)
    python3 "${SCRIPT_DIR}/voice_lab_automation.py" smoke "$@"
    ;;
  *)
    echo "uso: bash scripts/voice_lab.sh {bootstrap|health|list-profiles|latest-samples|train-latest|ingest|eval|smoke}" >&2
    exit 1
    ;;
esac
