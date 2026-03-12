#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${ROOT_DIR}/dist"
APP_BUNDLE="${DIST_DIR}/VoitranMac.app"
PKG_ROOT="${DIST_DIR}/pkgroot"
PKG_OUTPUT="${DIST_DIR}/VoitranMac.pkg"

bash "${ROOT_DIR}/scripts/build_voitran_macos_app.sh"

rm -rf "${PKG_ROOT}" "${PKG_OUTPUT}"
mkdir -p "${PKG_ROOT}/Applications"
cp -R "${APP_BUNDLE}" "${PKG_ROOT}/Applications/VoitranMac.app"

if command -v pkgbuild >/dev/null 2>&1; then
  pkgbuild \
    --root "${PKG_ROOT}" \
    --identifier "com.voitran.mac" \
    --version "0.1.0" \
    --install-location "/" \
    "${PKG_OUTPUT}"
  echo "[package_voitran_macos] pacote criado em ${PKG_OUTPUT}"
else
  ditto -c -k --sequesterRsrc --keepParent "${APP_BUNDLE}" "${DIST_DIR}/VoitranMac.zip"
  echo "[package_voitran_macos] pkgbuild indisponivel; zip criado em ${DIST_DIR}/VoitranMac.zip"
fi
