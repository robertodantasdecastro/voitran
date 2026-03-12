#!/usr/bin/env bash
set -euo pipefail

command_name="${1:-}"

case "${command_name}" in
  start)
    echo "[session] iniciar sessao"
    bash scripts/sync_memory.sh --check
    ;;
  continue)
    echo "[session] continuar sessao"
    ;;
  save)
    echo "[session] salvar checkpoint"
    bash scripts/sync_memory.sh --check
    ;;
  sync)
    echo "[session] sincronizar contexto"
    bash scripts/sync_memory.sh --check
    ;;
  triad)
    echo "[session] sincronizar Mac, Backend e AntigravityIDE"
    ;;
  *)
    echo "uso: bash scripts/session.sh {start|continue|save|sync|triad}" >&2
    exit 1
    ;;
esac
