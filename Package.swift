// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let settings: [SwiftSetting] = [
  .enableExperimentalFeature("StrictConcurrency")
]

let package = Package(
    name: "OJP",
    platforms: [.iOS(.v15), .macOS(.v14), .watchOS(.v9), .tvOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "OJP",
            targets: ["OJP"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CoreOffice/XMLCoder.git", from: "0.17.1"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.50.4"),
        .package(url: "https://github.com/longinius/swift-duration.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/swiftlang/swift-testing.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "OJP",
            dependencies: [
                .product(name: "XMLCoder", package: "xmlcoder"),
                .product(name: "Duration", package: "swift-duration"),
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "OJPTests",
            dependencies: [
                .byName(name:"OJP"),
                .product(
                    name: "Testing",
                    package: "swift-testing"),
            ],
            resources: [.process("Resources")],
            swiftSettings: settings
        ),
    ]
)

