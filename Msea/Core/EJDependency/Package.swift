// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// 依赖注入 DI（dependency-injection）
let package = Package(
    name: "EJDependency",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EJDependency",
            targets: [
                "EJDependency"
            ]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EJDependency"
        )
    ],
    swiftLanguageModes: [
        .v5
    ]
)
