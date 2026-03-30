// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ObjectScan",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "ObjectScan", targets: ["ObjectScan"])
    ],
    targets: [
        .target(
            name: "ObjectScan",
            path: "ObjectScan"
        )
    ]
)
