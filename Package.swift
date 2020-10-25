// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-hap-starter",
    platforms: [
        .macOS(.v10_11),
    ],
    dependencies: [
        .package(url: "https://github.com/Bouke/HAP.git", .branch("master")),
    ],
    targets: [
        .target(name: "swift-hap-starter", dependencies: ["HAP"]),
        .testTarget(name: "swift-hap-starterTests", dependencies: ["swift-hap-starter"]),
    ]
)
