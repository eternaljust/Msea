// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Home",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "IHome",
            targets: ["IHome"]
        ),
        .library(
            name: "MHome",
            targets: ["MHome"]
        )
    ],
    dependencies: [
        .package(name: "EJComponent", path: "../../Core/EJComponent"),
        .package(name: "EJRouter", path: "../../Core/EJRouter"),
        .package(name: "EJDependency", path: "../../Core/EJDependency"),
        .package(name: "Common", path: "../Base/Common"),
        .package(name: "AppTab", path: "../AppTab")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "IHome",
            dependencies: [
                .product(name: "EJRouter", package: "EJRouter"),
                .product(name: "AppTab", package: "AppTab")
            ],
            path: "Sources/Home/Interface"
        ),
        .target(
            name: "MHome",
            dependencies: [
                "IHome",
                .product(name: "EJBase", package: "EJComponent"),
                .product(name: "EJExtension", package: "EJComponent"),
                .product(name: "EJDependency", package: "EJDependency"),
                .product(name: "Common", package: "Common")
            ],
            path: "Sources/Home/Implementation"
        )
    ],
    swiftLanguageModes: [
        .v5
    ]
)
