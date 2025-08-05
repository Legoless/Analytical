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
        .library(
              name: "AnalyticalSingular",
              targets: ["AnalyticalSingular"]),
    ],
      dependencies: [
        .package(url: "https://github.com/singular-labs/Singular-iOS-SDK", .upToNextMajor(from: "12.1.1")),
      ],
    targets: [
        .target(
            name: "Analytical",
            path: "Analytical/Classes/Core/",
            swiftSettings: [
                .swiftLanguageMode(.v6),
              ]),
        .target(
              name: "AnalyticalSingular",
              dependencies: [
                .target(name: "Analytical"),
                .product(name: "Singular", package: "Singular-iOS-SDK")
              ],
              path: "Analytical/Classes/Provider/Singular/",
              swiftSettings: [
                .swiftLanguageMode(.v6)
              ]),
    ]
)
