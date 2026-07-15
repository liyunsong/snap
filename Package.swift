// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SnapApp",
    platforms: [
        .macOS(.v15)
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
            exclude: ["Resources/Info.plist"],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
