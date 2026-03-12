#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="${ROOT_DIR}/apps/macos/VoitranMac"
DIST_DIR="${ROOT_DIR}/dist"
APP_BUNDLE="${DIST_DIR}/VoitranMac.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
SCRIPTS_DIR="${RESOURCES_DIR}/scripts"
ICON_PATH="${DIST_DIR}/Voitran.icns"

mkdir -p "${DIST_DIR}"
(cd "${ROOT_DIR}" && bash "scripts/generate_voitran_app_icon.sh")
(cd "${APP_DIR}" && swift build -c release)

RELEASE_BIN="$(find "${APP_DIR}/.build" -type f -name VoitranMac -path '*release*' | head -1)"
if [[ -z "${RELEASE_BIN}" ]]; then
  echo "[build_voitran_macos_app] binario release nao encontrado" >&2
  exit 1
fi

rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}" "${SCRIPTS_DIR}"

cp "${RELEASE_BIN}" "${MACOS_DIR}/VoitranMac"
cp "${ROOT_DIR}/scripts/voice_runtime.sh" "${SCRIPTS_DIR}/voice_runtime.sh"
cp "${ROOT_DIR}/scripts/voice_lab.sh" "${SCRIPTS_DIR}/voice_lab.sh"
cp "${ROOT_DIR}/scripts/voice_lab_automation.py" "${SCRIPTS_DIR}/voice_lab_automation.py"
cp "${ROOT_DIR}/scripts/bootstrap_voice_runtime.sh" "${SCRIPTS_DIR}/bootstrap_voice_runtime.sh"
cp "${ROOT_DIR}/scripts/voice_sidecar.py" "${SCRIPTS_DIR}/voice_sidecar.py"
cp "${ROOT_DIR}/scripts/voice_sidecar_requirements.txt" "${SCRIPTS_DIR}/voice_sidecar_requirements.txt"
cp "${ROOT_DIR}/scripts/voitran_services.sh" "${SCRIPTS_DIR}/voitran_services.sh"
cp "${ICON_PATH}" "${RESOURCES_DIR}/Voitran.icns"
chmod +x "${SCRIPTS_DIR}/voice_runtime.sh" "${SCRIPTS_DIR}/voice_lab.sh" "${SCRIPTS_DIR}/bootstrap_voice_runtime.sh" "${SCRIPTS_DIR}/voitran_services.sh" "${SCRIPTS_DIR}/voice_lab_automation.py"

cat >"${CONTENTS_DIR}/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>pt-BR</string>
  <key>CFBundleExecutable</key>
  <string>VoitranMac</string>
  <key>CFBundleIdentifier</key>
  <string>com.voitran.mac</string>
  <key>CFBundleIconFile</key>
  <string>Voitran</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>VoitranMac</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>NSMicrophoneUsageDescription</key>
  <string>O Voitran precisa do microfone para gravar e clonar a voz local do usuario.</string>
</dict>
</plist>
EOF

touch "${CONTENTS_DIR}/PkgInfo"
echo "APPLVTRN" >"${CONTENTS_DIR}/PkgInfo"

echo "[build_voitran_macos_app] bundle pronto em ${APP_BUNDLE}"
