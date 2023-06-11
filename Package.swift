// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-openapi-request-dl",
    platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9)],
    products: [
        .library(
            name: "OpenAPIRequestDL",
            targets: ["OpenAPIRequestDL"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/request-dl/request-dl.git",
            from: "2.3.0"
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-runtime",
            from: "0.1.2"
        ),
        .package(
            url: "https://github.com/apple/swift-docc-plugin",
            from: "1.2.0"
        )
    ],
    targets: [
        .target(
            name: "OpenAPIRequestDL",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "RequestDL", package: "request-dl")
            ]
        ),
        .testTarget(
            name: "OpenAPIRequestDLTests",
            dependencies: ["OpenAPIRequestDL"]
        )
    ]
)
