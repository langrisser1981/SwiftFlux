// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftFlux",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "SwiftFlux",
            targets: ["SwiftFlux"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftFlux",
            dependencies: []),
        .testTarget(
            name: "SwiftFluxTests",
            dependencies: ["SwiftFlux"])
    ])
