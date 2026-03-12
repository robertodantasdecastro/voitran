#!/usr/bin/env bash
set -euo pipefail

mode="${1:-smoke}"

case "${mode}" in
  smoke)
    bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/voice_lab.sh" smoke
    ;;
  *)
    echo "[benchmark_local] modo=${mode}"
    echo "[benchmark_local] benchmark real sera implementado na Etapa 1A"
    ;;
esac
