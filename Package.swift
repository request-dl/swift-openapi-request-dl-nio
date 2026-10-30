// swift-tools-version: 6.3
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
    traits: [
        .trait(
            name: "NIOTransport",
            description: """
                Forwards RequestDL's `NIOTransport` trait, which pulls in AsyncHTTPClient/SwiftNIO/NIOSSL \
                and backs RequestDL's `.nio`/`.nioTransportServices` executors. Disabling it \
                (`--disable-default-traits`, or `traits: []` on the dependency) drops that whole \
                dependency subgraph and leaves the transport running over `.urlSession` only. \
                Darwin only: RequestDL's `.urlSession` executor is itself Darwin-exclusive, so \
                disabling this trait on any other platform leaves no executor at all and the \
                package won't build.
                """
        ),
        .default(enabledTraits: ["NIOTransport"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/request-dl/request-dl-nio",
            from: "4.5.5",
            // The condition lists `default` alongside `NIOTransport` on purpose. With `NIOTransport`
            // alone, SwiftPM's resolver fails ("exhausted attempts to resolve the dependencies graph")
            // for any consumer that takes this package's default traits, since it prunes request-dl-nio's
            // NIO packages before the default trait is expanded and then needs them.
            traits: [
                .trait(name: "NIOTransport", condition: .when(traits: ["default", "NIOTransport"]))
            ]
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-runtime",
            from: "1.13.3",
            traits: []
        ),
    ],
    targets: [
        .target(
            name: "OpenAPIRequestDL",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "RequestDL", package: "request-dl-nio"),
            ],
            swiftSettings: [.defaultIsolation(nil)]
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
