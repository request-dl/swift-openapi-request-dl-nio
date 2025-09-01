// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-openapi-request-dl-nio",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .visionOS(.v1)],
    products: [
        .library(
            name: "OpenAPIRequestDL",
            targets: ["OpenAPIRequestDL"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/request-dl/request-dl-nio.git",
            from: "3.0.3"
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-runtime",
            from: "1.8.2"
        ),
        .package(
            url: "https://github.com/apple/swift-docc-plugin",
            from: "1.4.5"
        )
    ],
    targets: [
        .target(
            name: "OpenAPIRequestDL",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "RequestDL", package: "request-dl-nio")
            ]
        ),
        .testTarget(
            name: "OpenAPIRequestDLTests",
            dependencies: [
                "OpenAPIRequestDL",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "RequestDL", package: "request-dl-nio")
            ]
        )
    ]
)
