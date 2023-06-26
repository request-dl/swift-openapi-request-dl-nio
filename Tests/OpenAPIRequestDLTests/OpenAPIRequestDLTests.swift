/*
 See LICENSE for this package's licensing information.
*/

import XCTest
import OpenAPIRuntime
import RequestDL
@testable import OpenAPIRequestDL

final class RequestDLClientTransportTests: XCTestCase {

    var transport: RequestDLClientTransport!

    override func setUp() async throws {
        try await super.setUp()
        transport = .init(content: EmptyProperty()) { request in
            MockedTask(
                status: .init(code: 200, reason: "Ok"),
                content: { request }
            )
            .collectData()
        }
    }

    override func tearDown() async throws {
        try await super.tearDown()
        transport = nil
    }

    func testClient_whenSend() async throws {
        // Given
        let data = Data("hello world!".utf8)

        let request = OpenAPIRuntime.Request(
            path: "/path/to/some/content",
            query: "id=102",
            method: .post,
            headerFields: [
                .init(name: "content-type", value: "application/json")
            ],
            body: data
        )

        // When
        let response = try await transport.send(
            request,
            baseURL: try XCTUnwrap(URL(string: "https://api.example.org/v1/")),
            operationID: "100"
        )

        // Then
        XCTAssertEqual(response.body, data)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.headerFields, [
            HeaderField(name: "Content-Type", value: "application/json"),
            HeaderField(name: "Content-Length", value: String(data.count))
        ])
    }

    func testClient_whenSendWithCustomConfiguration() async throws {
        // Given
        let transport = RequestDLClientTransport(
            content: PropertyGroup {
                AcceptHeader(.text)
            },
            task: { request in
                MockedTask(
                    status: .init(code: 202, reason: "Ok"),
                    content: { request }
                )
                .collectData()
            }
        )

        let data = Data("hello world!".utf8)

        let request = OpenAPIRuntime.Request(
            path: "/path/to/some/content",
            query: "id=102",
            method: .post,
            headerFields: [
                .init(name: "content-type", value: "application/json")
            ],
            body: data
        )

        // When
        let response = try await transport.send(
            request,
            baseURL: try XCTUnwrap(URL(string: "https://api.example.org/v1/")),
            operationID: "100"
        )

        // Then
        XCTAssertEqual(response.body, data)
        XCTAssertEqual(response.statusCode, 202)
        XCTAssertEqual(response.headerFields, [
            HeaderField(name: "Accept", value: "text/plain"),
            HeaderField(name: "Content-Type", value: "application/json"),
            HeaderField(name: "Content-Length", value: String(data.count))
        ])
    }
}
