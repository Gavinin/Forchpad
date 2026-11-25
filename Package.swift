// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Forchpad",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "Forchpad",
            path: "Sources/forchpad"
        )
    ]
)
