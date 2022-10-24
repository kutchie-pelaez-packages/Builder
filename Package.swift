// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Builder",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Builder", targets: ["Builder"])
    ],
    targets: [
        .target(name: "Builder", path: "Sources")
    ]
)
