// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NeedleSample",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Data", targets: ["Data"]),
        .library(name: "Presentation", targets: ["Presentation"]),
        .library(name: "DI", targets: ["DI"])
    ],
    dependencies: [
        .package(url: "https://github.com/uber/needle.git", .upToNextMajor(from: "0.25.1"))
        
    ],
    targets: [
        .target(name: "Domain", dependencies: []),
        .target(name: "Data", dependencies: ["Domain"]),
        .target(name: "Presentation", dependencies: ["Domain"]),
        .target(name: "DI", dependencies: ["Domain", "Data", "Presentation", .product(name: "NeedleFoundation", package: "needle")])
    ]
)
