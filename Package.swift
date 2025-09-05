// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ViewSwiftly",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ViewSwiftly",
            targets: ["ViewSwiftly"]),
    ],
    dependencies: [.package(url: "https://github.com/miramirrormira/NetSwiftly.git", branch: "main")],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ViewSwiftly",
            dependencies: ["NetSwiftly"]),
        .testTarget(
            name: "ViewSwiftlyTests",
            dependencies: ["ViewSwiftly"]),
    ]
)
