// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-openapi-request-dl-nio",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(
            name: "OpenAPIRequestDL",
            targets: ["OpenAPIRequestDL"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/request-dl/request-dl-nio.git",
            exact: "4.0.2"
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-runtime",
            from: "1.12.0"
        ),
    ],
    targets: [
        .target(
            name: "OpenAPIRequestDL",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "RequestDL", package: "request-dl-nio"),
            ]
        ),
        .testTarget(
            name: "OpenAPIRequestDLTests",
            dependencies: [
                "OpenAPIRequestDL",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "RequestDL", package: "request-dl-nio"),
            ]
        ),
    ]
)
