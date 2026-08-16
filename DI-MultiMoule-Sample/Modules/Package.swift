// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DIMultiModuleSample",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "DI", targets: ["DI"]),
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Data", targets: ["Data"]),
        .library(name: "Presentation", targets: ["Presentation"]),
        .library(name: "DIContainer", targets: ["DIContainer"])
    ],
    targets: [
        .target(name: "Domain", dependencies: ["DI"]),
        .target(name: "Data", dependencies: ["Domain", "DI"]),
        .target(name: "Presentation", dependencies: ["Domain", "DI"]),
        .target(name: "DI"),
        .target(name: "DIContainer", dependencies: ["DI", "Domain", "Data", "Presentation"])
    ]
)
