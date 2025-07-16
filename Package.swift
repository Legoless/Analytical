// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Analytical",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15),
        .watchOS(.v6),
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
            path: "Analytical/Classes/Core/",
            swiftSettings: [
                .swiftLanguageMode(.v6),
              ])
    ]
)
