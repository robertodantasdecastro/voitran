#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${ROOT_DIR}/dist"
ICONSET_DIR="${DIST_DIR}/Voitran.iconset"
ICNS_PATH="${DIST_DIR}/Voitran.icns"

rm -rf "${ICONSET_DIR}"
mkdir -p "${ICONSET_DIR}"

generate_png() {
  local size="$1"
  local output="$2"

  swift - "${size}" "${output}" <<'EOF'
import AppKit
import Foundation

let size = CGFloat(Int(CommandLine.arguments[1]) ?? 1024)
let outputPath = CommandLine.arguments[2]
let rect = CGRect(x: 0, y: 0, width: size, height: size)

let image = NSImage(size: rect.size)
image.lockFocus()

let background = NSBezierPath(roundedRect: rect, xRadius: size * 0.22, yRadius: size * 0.22)
let gradient = NSGradient(
    colors: [
        NSColor(calibratedRed: 0.97, green: 0.46, blue: 0.18, alpha: 1.0),
        NSColor(calibratedRed: 0.77, green: 0.13, blue: 0.11, alpha: 1.0),
        NSColor(calibratedRed: 0.17, green: 0.14, blue: 0.25, alpha: 1.0)
    ]
)!
gradient.draw(in: background, angle: -50)

NSGraphicsContext.current?.cgContext.setShadow(
    offset: CGSize(width: 0, height: -size * 0.035),
    blur: size * 0.08,
    color: NSColor(calibratedWhite: 0, alpha: 0.35).cgColor
)

let wave = NSBezierPath()
wave.lineCapStyle = .round
wave.lineJoinStyle = .round
wave.lineWidth = size * 0.085
wave.move(to: CGPoint(x: size * 0.24, y: size * 0.67))
wave.curve(
    to: CGPoint(x: size * 0.50, y: size * 0.30),
    controlPoint1: CGPoint(x: size * 0.33, y: size * 0.68),
    controlPoint2: CGPoint(x: size * 0.40, y: size * 0.33)
)
wave.curve(
    to: CGPoint(x: size * 0.76, y: size * 0.73),
    controlPoint1: CGPoint(x: size * 0.60, y: size * 0.27),
    controlPoint2: CGPoint(x: size * 0.67, y: size * 0.72)
)

NSColor(calibratedWhite: 1.0, alpha: 0.95).setStroke()
wave.stroke()

let pulse = NSBezierPath()
pulse.lineCapStyle = .round
pulse.lineJoinStyle = .round
pulse.lineWidth = size * 0.04
pulse.move(to: CGPoint(x: size * 0.28, y: size * 0.50))
pulse.line(to: CGPoint(x: size * 0.40, y: size * 0.50))
pulse.line(to: CGPoint(x: size * 0.46, y: size * 0.62))
pulse.line(to: CGPoint(x: size * 0.54, y: size * 0.38))
pulse.line(to: CGPoint(x: size * 0.60, y: size * 0.50))
pulse.line(to: CGPoint(x: size * 0.72, y: size * 0.50))

NSColor(calibratedRed: 1, green: 0.88, blue: 0.74, alpha: 0.9).setStroke()
pulse.stroke()

image.unlockFocus()

guard
    let tiff = image.tiffRepresentation,
    let rep = NSBitmapImageRep(data: tiff),
    let png = rep.representation(using: .png, properties: [:])
else {
    fputs("falha ao gerar PNG\n", stderr)
    exit(1)
}

try png.write(to: URL(fileURLWithPath: outputPath))
EOF
}

generate_png 16 "${ICONSET_DIR}/icon_16x16.png"
generate_png 32 "${ICONSET_DIR}/icon_16x16@2x.png"
generate_png 32 "${ICONSET_DIR}/icon_32x32.png"
generate_png 64 "${ICONSET_DIR}/icon_32x32@2x.png"
generate_png 128 "${ICONSET_DIR}/icon_128x128.png"
generate_png 256 "${ICONSET_DIR}/icon_128x128@2x.png"
generate_png 256 "${ICONSET_DIR}/icon_256x256.png"
generate_png 512 "${ICONSET_DIR}/icon_256x256@2x.png"
generate_png 512 "${ICONSET_DIR}/icon_512x512.png"
generate_png 1024 "${ICONSET_DIR}/icon_512x512@2x.png"

iconutil -c icns "${ICONSET_DIR}" -o "${ICNS_PATH}"
echo "[generate_voitran_app_icon] icone criado em ${ICNS_PATH}"
