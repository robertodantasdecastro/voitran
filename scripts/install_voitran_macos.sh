#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-/Applications}"
APP_TARGET="${TARGET_DIR}/VoitranMac.app"
APP_NAME="VoitranMac"

if pgrep -x "${APP_NAME}" >/dev/null 2>&1; then
  osascript -e "tell application \"${APP_NAME}\" to quit" >/dev/null 2>&1 || true
  for _ in $(seq 1 20); do
    if ! pgrep -x "${APP_NAME}" >/dev/null 2>&1; then
      break
    fi
    sleep 0.5
  done
fi

bash "${ROOT_DIR}/scripts/build_voitran_macos_app.sh"
mkdir -p "${TARGET_DIR}"
rm -rf "${APP_TARGET}"
ditto "${ROOT_DIR}/dist/VoitranMac.app" "${APP_TARGET}"
bash "${ROOT_DIR}/scripts/bootstrap_voice_runtime.sh"

cat <<EOF
[install_voitran_macos] app instalada em ${APP_TARGET}
[install_voitran_macos] runtime local preparado em /Volumes/SSDExterno/Voitran_runtime
[install_voitran_macos] reinicie o app apos a instalacao para carregar a versao nova
EOF
