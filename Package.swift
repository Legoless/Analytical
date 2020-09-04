// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Analytical",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12),
        .watchOS(.v5),
        .tvOS(.v9)
    ],
    products: [
        .library(
            name: "Analytical",
            targets: ["Analytical"]),
    ],
    targets: [
        .target(
            name: "Analytical",
            path: "Analytical/Classes/Core/")
    ]
)
