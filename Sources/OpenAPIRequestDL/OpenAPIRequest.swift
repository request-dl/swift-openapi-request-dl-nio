/*
 See LICENSE for this package's licensing information.
*/

import OpenAPIRuntime
import HTTPTypes
import RequestDL
import Foundation

struct OpenAPIRequest: Property {

    let baseURL: URL
    let request: HTTPRequest
    let httpBody: HTTPBody?

    var body: some Property {
        if let urlComponents {
            if let host = urlComponents.host {
                if let scheme = urlComponents.scheme {
                    BaseURL(.init(scheme), host: host)
                } else {
                    BaseURL(host)
                }
            }

            if !urlComponents.path.isEmpty {
                Path(urlComponents.path)
            }

            if let queries = urlComponents.queryItems {
                PropertyForEach(queries, id: \.self) { query in
                    Query(name: query.name, value: query.value)
                }
            }
        }

        AsyncProperty {
            if let data = try await data {
                Payload(data: data)
            }
        }

        RequestMethod(.init(request.method.rawValue))

        PropertyForEach(request.headerFields.enumerated(), id: \.1) { (offset, header) in
            CustomHeader(name: header.name.rawName, value: header.value)
                .headerStrategy(offset == .zero ? .setting : .adding)
                .headerSeparator(header.name == .cookie ? ";" : ",")
        }
    }

    private var urlComponents: URLComponents? {
        URLComponents(string: baseURL.absoluteString).flatMap { baseComponents in
            URLComponents(string: request.path ?? "").map {
                var baseComponents = baseComponents
                baseComponents.percentEncodedPath += $0.percentEncodedPath
                baseComponents.percentEncodedQuery = $0.percentEncodedQuery
                return baseComponents
            }
        }
    }

    private var data: Data? {
        get async throws {
            guard let httpBody else {
                return nil
            }

            var data = Data()
            for try await bytes in httpBody {
                data.append(contentsOf: bytes)
            }
            return data
        }
    }
}
