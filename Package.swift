// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NotificationService",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "NotificationService",
            targets: ["NotificationService"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NotificationService",
            dependencies: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "NotificationServiceTests",
            dependencies: ["NotificationService"]
        ),
    ]
)
