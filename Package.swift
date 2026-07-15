// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SnapApp",
    platforms: [
        .macOS(.v15)  // macOS 15 Sequoia or later
    ],
    products: [
        .executable(
            name: "SnapApp",
            targets: ["SnapApp"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "SnapApp",
            dependencies: ["KeyboardShortcuts"],
            path: "SnapApp",
            exclude: ["Resources/Info.plist"]
        )
    ]
)
