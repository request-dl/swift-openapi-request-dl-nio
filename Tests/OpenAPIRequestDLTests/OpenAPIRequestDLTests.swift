/*
 See LICENSE for this package's licensing information.
*/

import XCTest
import OpenAPIRuntime
import RequestDL
import HTTPTypes
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

        let request = HTTPRequest(
            method: .post,
            scheme: nil,
            authority: nil,
            path: "/path/to/some/content?id=102",
            headerFields: .init([
                HTTPField(
                    name: try XCTUnwrap(HTTPField.Name("content-type")),
                    value: "application/json"
                )
            ])
        )

        // When
        let (response, body) = try await transport.send(
            request,
            body: .init(data, length: .known(Int64(data.count))),
            baseURL: try XCTUnwrap(URL(string: "https://api.example.org/v1/")),
            operationID: "100"
        )

        let receivedData = try await body?.toData()

        // Then
        try XCTAssertEqual(XCTUnwrap(receivedData), data)
        XCTAssertEqual(response.status.code, 200)
        XCTAssertEqual(response.headerFields, .init([
            try HTTPField(
                name: XCTUnwrap(HTTPField.Name("Content-Type")),
                value: "application/json"
            ),
            try HTTPField(
                name: XCTUnwrap(HTTPField.Name("Content-Length")),
                value: String(data.count)
            )
        ]))
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

        let request = HTTPRequest(
            method: .post,
            scheme: nil,
            authority: nil,
            path: "/path/to/some/content?id=102",
            headerFields: .init([
                try HTTPField(
                    name: XCTUnwrap(HTTPField.Name("content-type")),
                    value: "application/json"
                )
            ])
        )

        // When
        let (response, body) = try await transport.send(
            request,
            body: .init(data, length: .known(Int64(data.count))),
            baseURL: try XCTUnwrap(URL(string: "https://api.example.org/v1/")),
            operationID: "100"
        )

        let receivedData = try await body?.toData()

        // Then
        XCTAssertEqual(receivedData, data)
        XCTAssertEqual(response.status.code, 202)
        XCTAssertEqual(response.headerFields, .init([
            try HTTPField(
                name: XCTUnwrap(HTTPField.Name("Accept")),
                value: "text/plain"
            ),
            try HTTPField(
                name: XCTUnwrap(HTTPField.Name("Content-Type")),
                value: "application/json"
            ),
            try HTTPField(
                name: XCTUnwrap(HTTPField.Name("Content-Length")),
                value: String(data.count)
            )
        ]))
    }
}

extension HTTPBody {

    func toData() async throws -> Data {
        var data = Data()
        for try await bytes in self {
            data.append(contentsOf: bytes)
        }
        return data
    }
}
