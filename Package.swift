// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SBTUITestTunnelHost",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "SBTUITestTunnelHost",
            targets: ["SBTUITestTunnelHost"]
        ),
    ],
    targets: [
        .target(
            name: "SBTUITestTunnelHost",
            path: "SBTUITestTunnelHost",
            publicHeadersPath: "",
            linkerSettings: [
                .linkedFramework("CoreGraphics"),
                .linkedFramework("XCTest"),
            ]
        ),
    ]
)
