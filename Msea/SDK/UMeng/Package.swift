// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UMeng",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "UMeng",
            targets: ["UMeng"]
        )
    ],
    targets: [
        // 1. 二进制依赖库
        .binaryTarget(
            name: "UMCommon",
            path: "UMCommon.xcframework"
        ),
        .binaryTarget(
            name: "UMDevice",
            path: "UMDevice.xcframework"
        ),

        // 2. 桥接的 UMeng
        .target(
            name: "UMeng",
            dependencies: [
                "UMCommon",
                "UMDevice"
            ],
            linkerSettings: [
                .linkedFramework("CoreTelephony"),
                .linkedFramework("SystemConfiguration"),
                .linkedLibrary("z"),
                .linkedLibrary("sqlite3")
            ]
        )
    ]
)
