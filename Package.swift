// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftAsyncKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(name: "SwiftAsyncKit", targets: ["SwiftAsyncKit"])
    ],
    targets: [
        .target(name: "SwiftAsyncKit"),
        .testTarget(name: "SwiftAsyncKitTests", dependencies: ["SwiftAsyncKit"])
    ]
)
