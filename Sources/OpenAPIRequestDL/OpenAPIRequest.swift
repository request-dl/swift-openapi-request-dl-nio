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

        PropertyForEach(request.headerFields, id: \.self) { header in
            CustomHeader(name: header.name, value: header.value)
        }

        RequestMethod(.init(request.method.name))
    }
}
