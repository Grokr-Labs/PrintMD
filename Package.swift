// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PrintMD",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PrintMD", targets: ["PrintMDApp"]),
        .library(name: "PrintMDCore", targets: ["PrintMDCore"])
    ],
    dependencies: [],
    targets: [
        // Main application
        .executableTarget(
            name: "PrintMDApp",
            dependencies: ["PrintMDCore", "PrintMDDriver"],
            path: "Sources/PrintMDApp",
            swiftSettings: [
                .unsafeFlags(["-suppress-warnings"])
            ]
        ),

        // Printer driver system extension
        .target(
            name: "PrintMDDriver",
            dependencies: ["PrintMDCore"],
            path: "Sources/PrintMDDriver",
            publicHeadersPath: "."
        ),

        // Core business logic
        .target(
            name: "PrintMDCore",
            path: "Sources/PrintMDCore",
            publicHeadersPath: "."
        ),

        // Unit tests
        .testTarget(
            name: "CoreTests",
            dependencies: ["PrintMDCore"],
            path: "Tests/CoreTests"
        ),

        // Integration tests
        .testTarget(
            name: "IntegrationTests",
            dependencies: ["PrintMDApp", "PrintMDCore"],
            path: "Tests/IntegrationTests"
        )
    ]
)
