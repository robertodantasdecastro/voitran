#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"

case "${mode}" in
  bootstrap)
    bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bootstrap_voice_runtime.sh"
    ;;
  health)
    bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/voice_runtime.sh" health
    ;;
  list-profiles)
    bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/voice_runtime.sh" list-profiles
    ;;
  ingest)
    bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/voice_runtime.sh" health
    ;;
  eval)
    bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/voice_runtime.sh" list-profiles
    ;;
  *)
    echo "uso: bash scripts/voice_lab.sh {bootstrap|health|list-profiles|ingest|eval}" >&2
    exit 1
    ;;
esac
