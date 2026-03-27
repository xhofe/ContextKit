// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ContextKitPluginSDK",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "ContextKitPluginSDK",
            targets: ["ContextKitPluginSDK"]
        ),
    ],
    targets: [
        .target(
            name: "ContextKitPluginSDK"
        ),
        .testTarget(
            name: "ContextKitPluginSDKTests",
            dependencies: ["ContextKitPluginSDK"]
        ),
    ]
)
