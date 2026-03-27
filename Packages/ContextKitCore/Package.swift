// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ContextKitCore",
    defaultLocalization: "en",
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
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "ContextKitCoreTests",
            dependencies: ["ContextKitCore"]
        ),
    ]
)
