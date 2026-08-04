/*
 See LICENSE for this package's licensing information.
*/

import Foundation
import HTTPTypes
import OpenAPIRuntime
import RequestDL
import Testing

@testable import OpenAPIRequestDL

// RequestDL (async-fixes branch, PropertyMockedTask): `MockedTask` now injects a synthetic
// `rdl-request-method` header into every mocked response, reflecting the resolved request's
// HTTP method. See request-dl-nio commit 8ce3d552 ("Fixes MockedTask Behavior").
private let mockedRequestMethodHeaderName = "rdl-request-method"

@Suite struct RequestDLClientTransportTests {

    let transport: RequestDLClientTransport

    init() {
        transport = .init(content: EmptyProperty()) { request in
            MockedTask(
                status: .init(code: 200, reason: "Ok"),
                content: { request }
            )
            .collectData()
        }
    }

    @Test func send() async throws {
        // Given
        let data = Data("hello world!".utf8)

        let contentTypeFieldName = try #require(HTTPField.Name("content-type"))

        let request = HTTPRequest(
            method: .post,
            scheme: nil,
            authority: nil,
            path: "/path/to/some/content?id=102",
            headerFields: .init([
                HTTPField(name: contentTypeFieldName, value: "application/json")
            ])
        )

        let baseURL = try #require(URL(string: "https://api.example.org/v1/"))

        // When
        let (response, body) = try await transport.send(
            request,
            body: .init(data, length: .known(Int64(data.count))),
            baseURL: baseURL,
            operationID: "100"
        )

        let receivedData = try await body?.toData()
        let unwrappedReceivedData = try #require(receivedData)

        let contentTypeHeaderName = try #require(HTTPField.Name("Content-Type"))
        let contentLengthHeaderName = try #require(HTTPField.Name("Content-Length"))
        let mockedMethodHeaderName = try #require(HTTPField.Name(mockedRequestMethodHeaderName))

        // Then
        #expect(unwrappedReceivedData == data)
        #expect(response.status.code == 200)
        #expect(
            response.headerFields
                == .init([
                    HTTPField(name: contentTypeHeaderName, value: "application/json"),
                    HTTPField(name: contentLengthHeaderName, value: String(data.count)),
                    HTTPField(name: mockedMethodHeaderName, value: "POST"),
                ])
        )
    }

    @Test func sendWithCustomConfiguration() async throws {
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

        let contentTypeFieldName = try #require(HTTPField.Name("content-type"))

        let request = HTTPRequest(
            method: .post,
            scheme: nil,
            authority: nil,
            path: "/path/to/some/content?id=102",
            headerFields: .init([
                HTTPField(name: contentTypeFieldName, value: "application/json")
            ])
        )

        let baseURL = try #require(URL(string: "https://api.example.org/v1/"))

        // When
        let (response, body) = try await transport.send(
            request,
            body: .init(data, length: .known(Int64(data.count))),
            baseURL: baseURL,
            operationID: "100"
        )

        let receivedData = try await body?.toData()

        let acceptHeaderName = try #require(HTTPField.Name("Accept"))
        let contentTypeHeaderName = try #require(HTTPField.Name("Content-Type"))
        let contentLengthHeaderName = try #require(HTTPField.Name("Content-Length"))
        let mockedMethodHeaderName = try #require(HTTPField.Name(mockedRequestMethodHeaderName))

        // Then
        #expect(receivedData == data)
        #expect(response.status.code == 202)
        #expect(
            response.headerFields
                == .init([
                    HTTPField(name: acceptHeaderName, value: "text/plain"),
                    HTTPField(name: contentTypeHeaderName, value: "application/json"),
                    HTTPField(name: contentLengthHeaderName, value: String(data.count)),
                    HTTPField(name: mockedMethodHeaderName, value: "POST"),
                ])
        )
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
