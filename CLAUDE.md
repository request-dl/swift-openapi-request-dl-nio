# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`swift-openapi-request-dl-nio` is a Swift Package that bridges [swift-openapi-generator](https://github.com/apple/swift-openapi-generator)-generated clients to [RequestDL](https://github.com/request-dl/request-dl-nio). It provides `RequestDLClientTransport`, a `ClientTransport` implementation (from `OpenAPIRuntime`) so generated OpenAPI clients can execute requests through RequestDL instead of `URLSession`/Foundation networking.

The public surface is intentionally tiny: one public type (`RequestDLClientTransport`) and one internal helper (`OpenAPIRequest`).

## Commands

Build:
```sh
swift build
```

Run all tests:
```sh
swift test
```

Run a single test:
```sh
swift test --filter RequestDLClientTransportTests/testClient_whenSend
```

Format check (matches CI's `enable-format` step, config in `.swift-format`):
```sh
swift format lint --recursive Sources Tests
```

Format in place:
```sh
swift format --in-place --recursive Sources Tests
```

CI (`.github/workflows/swift-ci.yaml`) runs against Swift 6.2 / Xcode 26.6 on `macos-26` via the shared `request-dl/.github` reusable workflow, and includes: format check, breaking-change detection (skipped on major version bumps), Apple-platform tests with coverage, third-party (Linux/Foundation Essentials) tests with coverage, and coverage upload. It only triggers on changes to `Package.swift`, `Sources/**`, `Tests/**`, and `.swift-format`.

## Architecture

Two files do all the work, both under `Sources/OpenAPIRequestDL/`:

- **`RequestDLClientTransport.swift`** (public) — implements `ClientTransport.send(_:body:baseURL:operationID:)`. It wraps user-supplied RequestDL `Property` content (passed via `@PropertyBuilder` in `init`) together with an `OpenAPIRequest` inside a `PropertyGroup`, executes it as a `DownloadTask` by default and converts the resulting `TaskResult<AsyncBytes>` back into `(HTTPResponse, HTTPBody?)`, streaming the response body instead of buffering it. The `task` closure (`@Sendable (AnyProperty) -> any RequestTask<TaskResult<AsyncBytes>>`) is public and overridable via `init(content:task:)`, so callers can swap in RequestDL task modifiers (progress tracking, interceptors, logger, `onStatusCode`, etc.) as long as the result stays `TaskResult<AsyncBytes>` — see `MockedTask` usage in tests for the pattern. Response headers are translated from RequestDL's header representation into `HTTPFields`; `Content-Length` (when present) drives `HTTPBody.Length.known`, otherwise `.unknown` is used, and `iterationBehavior` is `.single` since the underlying stream can only be consumed once.

- **`OpenAPIRequest.swift`** (internal) — a RequestDL `Property` that translates an `OpenAPIRuntime.HTTPRequest`/`HTTPBody` into RequestDL primitives:
  - `baseURL` + `request.path` are merged into `URLComponents` (percent-encoded path/query preserved), then split into `BaseURL`, `Path`, and `Query` properties.
  - `httpBody` is drained asynchronously into `Data` and emitted as `Payload` inside an `AsyncProperty`.
  - `request.method` becomes `RequestMethod`.
  - `request.headerFields` are replayed as `CustomHeader`s — the first header uses `.headerStrategy(.setting)` and subsequent ones use `.adding`, and the `Cookie` header uses `;` as its separator instead of the default `,`.

When modifying request/response translation, both files usually need to be considered together: `RequestDLClientTransport` owns the transport-level flow (task execution, response reconstruction), while `OpenAPIRequest` owns request-level flow (how an `HTTPRequest` maps to RequestDL's declarative property tree).

### Testing pattern

Tests inject a fake `task` closure that returns a `MockedTask` (from RequestDL's test utilities) instead of hitting the network, then assert on the resulting `HTTPResponse`/`HTTPBody`. Either the internal `init(content: Content, task:)` (value-based content, `@testable import`-only) or the public `init(content: () -> Content, task:)` (`@PropertyBuilder` + trailing-closure `task:`) work for this. Mocked results must resolve to `TaskResult<AsyncBytes>` (e.g. `MockedTask { ... }.collectBytes()`, not `.collectData()`).

## Code style

Formatting is enforced by `swift-format` using `.swift-format` at the repo root — notably: 4-space indentation, 120-char line length, imports ordered, file-scoped declarations default to `private`, triple-slash doc comments, no block comments. Run the format commands above before committing.

## Dependencies

- `RequestDL` — pinned to `4.0.2` (exact version) of `request-dl/request-dl-nio` in `Package.swift`.
- `swift-openapi-runtime` — from `1.12.0`.
