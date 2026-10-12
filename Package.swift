// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LibaiApp",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "LibaiApp",
            targets: ["LibaiApp"]
        ),
    ],
    targets: [
        .target(
            name: "LibaiApp",
            path: "LibaiApp"
        ),
    ]
)
