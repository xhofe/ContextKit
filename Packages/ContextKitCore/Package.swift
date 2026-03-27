// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ContextKitCore",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "ContextKitCore",
            targets: ["ContextKitCore"]
        ),
    ],
    dependencies: [
        .package(path: "../ContextKitPluginSDK"),
    ],
    targets: [
        .target(
            name: "ContextKitCore",
            dependencies: [
                .product(name: "ContextKitPluginSDK", package: "ContextKitPluginSDK"),
            ]
        ),
        .testTarget(
            name: "ContextKitCoreTests",
            dependencies: ["ContextKitCore"]
        ),
    ]
)
