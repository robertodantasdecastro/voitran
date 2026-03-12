#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-/Applications}"
APP_TARGET="${TARGET_DIR}/VoitranMac.app"

bash "${ROOT_DIR}/scripts/build_voitran_macos_app.sh"
mkdir -p "${TARGET_DIR}"
rm -rf "${APP_TARGET}"
ditto "${ROOT_DIR}/dist/VoitranMac.app" "${APP_TARGET}"
bash "${ROOT_DIR}/scripts/bootstrap_voice_runtime.sh"

cat <<EOF
[install_voitran_macos] app instalada em ${APP_TARGET}
[install_voitran_macos] runtime local preparado em /Volumes/SSDExterno/Voitran_runtime
EOF
