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
	dependencies: [
		.package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.5.0"),
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
		.package(url: "https://github.com/apple/swift-foundation.git", branch: "main"),
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "swift-md-bulk-renamer",
			dependencies: [
				.product(name: "Markdown", package: "swift-markdown"),
				.product(
					name: "FoundationEssentials",
					package: "swift-foundation",
					condition: .when(platforms: [.linux, .windows])
				),
			]
		),
		.executableTarget(
			name: "mvmd",
			dependencies: [
				"swift-md-bulk-renamer",
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(
					name: "FoundationEssentials",
					package: "swift-foundation",
					condition: .when(platforms: [.linux, .windows])
				),
			]
		),
		.testTarget(
			name: "swift-md-bulk-renamer-tests",
			dependencies: [
				"swift-md-bulk-renamer",
				.product(
					name: "FoundationEssentials",
					package: "swift-foundation",
					condition: .when(platforms: [.linux, .windows])
				),
			]
		),
	]
)
