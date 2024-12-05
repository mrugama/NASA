// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "Endpoint", targets: ["Endpoint"]),
    ],
    targets: [
        .target(
            name: "Networking",
            path: "Sources/Foundation/Networking"
        ),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"]
        ),
        .target(
            name: "Endpoint",
            path: "Sources/Foundation/Endpoint"
        ),
    ]
)
