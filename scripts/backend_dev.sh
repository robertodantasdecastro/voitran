#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="${ROOT_DIR}/backend/control-plane"

mode="${1:-}"

case "${mode}" in
  build)
    (cd "${BACKEND_DIR}" && go build ./...)
    ;;
  test)
    (cd "${BACKEND_DIR}" && go test ./...)
    ;;
  run)
    (cd "${BACKEND_DIR}" && go run ./cmd/server)
    ;;
  *)
    echo "uso: bash scripts/backend_dev.sh {build|test|run}" >&2
    exit 1
    ;;
esac
