[![Swift Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Frequest-dl%2Fswift-openapi-request-dl-nio%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/request-dl/swift-openapi-request-dl-nio)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Frequest-dl%2Fswift-openapi-request-dl-nio%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/request-dl/swift-openapi-request-dl-nio)
[![codecov](https://codecov.io/gh/request-dl/swift-openapi-request-dl-nio/graph/badge.svg?token=Cz6ro3SEc3)](https://codecov.io/gh/request-dl/swift-openapi-request-dl-nio)

# OpenAPIRequestDL

The `RequestDLClientTransport` enables the use of the `OpenAPI` format along with all the available configuration properties provided by `RequestDL`.

To generate code for the objects, you should use the [Swift OpenAPI Generator](https://github.com/apple/swift-openapi-generator).

Additionally, Apple has provided all the details in the WWDC23 session [Meet Swift OpenAPI Generator](https://developer.apple.com/wwdc23/10171).

- [Documentation](https://swiftpackageindex.com/request-dl/swift-openapi-request-dl-nio/main/documentation/openapirequestdl)

## Installation

OpenAPIRequestDL can be installed using Swift Package Manager. To include it in your project,
add the following dependency to your Package.swift file:

```swift
dependencies: [
    .package(url: "https://github.com/request-dl/swift-openapi-request-dl-nio.git", from: "1.0.1")
]
```

## Versioning

We follow semantic versioning for this project. The version number is composed of three parts: MAJOR.MINOR.PATCH.

- MAJOR version: Increments when there are incompatible changes and breaking changes. These changes may require updates to existing code and could potentially break backward compatibility.

- MINOR version: Increments when new features or enhancements are added in a backward-compatible manner. It may include improvements, additions, or modifications to existing functionality.

- The PATCH version includes bug fixes, patches, and safe modifications that address issues, bugs, or vulnerabilities without disrupting existing functionality. It may also include new features, but they must be implemented carefully to avoid breaking changes or compatibility issues.

It is recommended to review the release notes for each version to understand the specific changes and updates made in that particular release.

## Contributing

If you find a bug or have an idea for a new feature, please open an issue or
submit a pull request. We welcome contributions from the community!
