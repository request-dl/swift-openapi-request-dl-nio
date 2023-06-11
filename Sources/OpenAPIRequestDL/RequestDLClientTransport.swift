/*
 See LICENSE for this package's licensing information.
*/

import OpenAPIRuntime
import RequestDL
import Foundation

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
        _ request: OpenAPIRuntime.Request,
        baseURL: URL,
        operationID: String
    ) async throws -> OpenAPIRuntime.Response {

        let scheme = baseURL.scheme ?? "http"
        let url = baseURL.absoluteString.replacingOccurrences(
            of: scheme + "://",
            with: ""
        )
        var components = url.split(separator: "/")
        let baseURL = components.removeFirst()

        let response = try await task(AnyProperty(
            PropertyGroup {
                content

                BaseURL(.init(scheme), host: String(baseURL))
                PropertyForEach(components, id: \.self) {
                    Path($0)
                }

                OpenAPIRequest(request: request)
            }
        ))
        .result()

        return .init(
            statusCode: Int(response.head.status.code),
            headerFields: response.head.headers.map {
                .init(name: $0, value: $1)
            },
            body: response.payload
        )
    }
}
