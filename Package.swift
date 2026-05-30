// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Agent07UI",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "Agent07UI", targets: ["Agent07UI"])
    ],
    targets: [
        .target(name: "Agent07UI"),
        .testTarget(
            name: "Agent07UITests",
            dependencies: ["Agent07UI"]
        )
    ],
    swiftLanguageModes: [.v6]
)
