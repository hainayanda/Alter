// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Alter",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "Alter",
            targets: ["Alter"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "3.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0")
    ],
    targets: [
        .target(
            name: "Alter",
            dependencies: [],
            path: "Alter/Classes"
        ),
        .testTarget(
            name: "AlterTests",
            dependencies: [
                "Alter", "Quick", "Nimble"
            ],
            path: "Example/Tests"
        )
    ]
)
