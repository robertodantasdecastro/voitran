// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VoitranMac",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "VoitranMac",
            targets: ["VoitranMacApp"]
        )
    ],
    dependencies: [
        .package(path: "../../../packages/realtime-core-swift")
    ],
    targets: [
        .executableTarget(
            name: "VoitranMacApp",
            dependencies: [
                .product(name: "RealtimeCore", package: "realtime-core-swift")
            ]
        )
    ]
)
