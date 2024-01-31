/*
 See LICENSE for this package's licensing information.
*/

import OpenAPIRuntime
import RequestDL
import Foundation
import HTTPTypes

/**
 A `ClientTransport` that utilizes `RequestDL` to execute HTTP requests.

 When creating the `Client` for `OpenAPIRuntime`, the instantiated transport should be provided as
 shown in the example:

 ```swift
 Client(
     serverURL: try! Servers.server1(),
     transport: RequestDLClientTransport()
 )
 ```

 You can add extra configurations if necessary to maintain communication security with the server:

 ```swift
 RequestDLClientTransport {
     SecureConnection {
        AdditionalTrusts("apple.com")
        // Add more properties as needed
     }
 }
 ```

 Furthermore, you can combine any other necessary `Property` objects to customize your request, just
 specify them as shown in the example above.
 */
public struct RequestDLClientTransport: ClientTransport {

    // MARK: - Private properties

    private let content: AnyProperty
    private let task: @Sendable (AnyProperty) -> any RequestTask<TaskResult<Data>>

    // MARK: - Inits

    /// Instancia o `RequestDLClientTransport`.
    public init() {
        self.init(content: EmptyProperty.init)
    }

    /**
     Initializes the `RequestDLClientTransport` with a content closure that returns a `Property`
     object.

     - Parameter content: A closure that returns a `Property` object, which specifies the properties
     of the request.

     Example usage:

     ```swift
     let transport = RequestDLClientTransport {
         BaseURL("https://api.example.com")
         RequestMethod(.post)
         // Add more properties as needed
     }

     let client = Client(
         serverURL: try! Servers.server1(),
         transport: transport
     )
     ```
     */
    public init<Content: Property>(@PropertyBuilder content: () -> Content) {
        self.init(
            content: content(),
            task: { request in DataTask { request }}
        )
    }

    init<Content: Property>(
        content: Content,
        task: @escaping @Sendable (AnyProperty) -> any RequestTask<TaskResult<Data>>
    ) {
        self.content = .init(content)
        self.task = task
    }

    // MARK: - Public methods

    public func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let response = try await task(AnyProperty(
            PropertyGroup {
                content

                OpenAPIRequest(
                    baseURL: baseURL,
                    request: request,
                    httpBody: body
                )
            }
        ))
        .result()

        var headers = HTTPFields()
        for header in response.head.headers {
            if let name = HTTPField.Name(header.name) {
                headers.append(HTTPField(
                    name: name,
                    value: header.value
                ))
            }
        }

        return (
            HTTPResponse(
                status: HTTPResponse.Status(
                    integerLiteral: Int(response.head.status.code)
                ),
                headerFields: headers
            ),
            HTTPBody(
                response.payload,
                length: .known(Int64(response.payload.count)),
                iterationBehavior: .multiple
            )
        )
    }
}
