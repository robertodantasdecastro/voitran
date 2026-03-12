// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RealtimeCore",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "RealtimeCore",
            targets: ["RealtimeCore"]
        )
    ],
    targets: [
        .target(
            name: "RealtimeCore"
        )
    ]
)
