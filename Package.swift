// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Analytical",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_12),
        .watchOS(.v5),
        .tvOS(.v13)
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
