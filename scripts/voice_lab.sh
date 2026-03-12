#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"

case "${mode}" in
  ingest)
    echo "[voice_lab] ingest placeholder"
    ;;
  eval)
    echo "[voice_lab] eval placeholder"
    ;;
  *)
    echo "uso: bash scripts/voice_lab.sh {ingest|eval}" >&2
    exit 1
    ;;
esac
