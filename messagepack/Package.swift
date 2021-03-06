// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "messagepack-example",
    dependencies: [
        .package(
            url: "https://github.com/tris-code/messagepack.git",
            .branch("master"))
    ],
    targets: [
        .target(name: "main", dependencies: ["MessagePack"])
    ]
)
