// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ContextKitBuiltins",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "ContextKitBuiltins",
            targets: ["ContextKitBuiltins"]
        ),
    ],
    dependencies: [
        .package(path: "../ContextKitCore"),
    ],
    targets: [
        .target(
            name: "ContextKitBuiltins",
            dependencies: [
                .product(name: "ContextKitCore", package: "ContextKitCore"),
            ]
        ),
        .testTarget(
            name: "ContextKitBuiltinsTests",
            dependencies: ["ContextKitBuiltins"]
        ),
    ]
)
