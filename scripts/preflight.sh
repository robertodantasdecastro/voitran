#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="/Volumes/SSDExterno/Voitran_runtime"

echo "[preflight] root: ${ROOT_DIR}"

if [[ ! -d "${RUNTIME_DIR}" ]]; then
  echo "[preflight] runtime externo ausente: ${RUNTIME_DIR}" >&2
  exit 1
fi

for required in models caches voices vector logs; do
  if [[ ! -d "${RUNTIME_DIR}/${required}" ]]; then
    echo "[preflight] subdiretorio ausente: ${RUNTIME_DIR}/${required}" >&2
    exit 1
  fi
done

echo "[preflight] ok"
