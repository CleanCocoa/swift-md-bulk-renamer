// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-md-bulk-renamer",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "swift-md-bulk-renamer",
            targets: ["swift-md-bulk-renamer"]
        ),
        .executable(
            name: "mvmd",
            targets: ["mvmd"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "swift-md-bulk-renamer"
        ),
        .executableTarget(
            name: "mvmd",
            dependencies: [
                "swift-md-bulk-renamer"
            ]
        ),
        .testTarget(
            name: "swift-md-bulk-renamerTests",
            dependencies: ["swift-md-bulk-renamer"]
        ),
    ]
)
