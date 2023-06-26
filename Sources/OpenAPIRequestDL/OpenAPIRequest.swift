/*
 See LICENSE for this package's licensing information.
*/

import OpenAPIRuntime
import RequestDL
import Foundation

struct OpenAPIRequest: Property {

    let request: OpenAPIRuntime.Request

    var body: some Property {
        if let data = request.body {
            Payload(data: data)
        }

        if let query = request.query {
            Path(request.path + (query.hasPrefix("?") ? query : "?\(query)"))
        } else {
            Path(request.path)
        }

        RequestMethod(.init(request.method.name))

        let headers = HTTPHeaders(request.headerFields.map { ($0.name, $0.value) })

        PropertyForEach(headers.names, id: \.self) { name in
            PropertyForEach((headers[name] ?? []).enumerated(), id: \.offset) { offset, value in
                CustomHeader(name: name, value: value)
                    .headerStrategy(offset == .zero ? .setting : .adding)
            }
        }
    }
}
