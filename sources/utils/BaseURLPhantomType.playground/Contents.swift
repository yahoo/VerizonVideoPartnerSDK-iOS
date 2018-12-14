import Foundation

struct BaseURL {
    enum Error: Swift.Error {
        case malformedUrl(from: String)
        case hasPath(in: String)
        case emptyHost(in: String)
        case unsupportedScheme(in: String)
        case unableToCreateBaseUrl(from: String)
    }
    
    let value: URL
    
    init(string: String) throws {
        guard let comps = URLComponents(string: string) else {
            throw Error.malformedUrl(from: string)
        }
        guard comps.path.count == 0 else {
            throw Error.hasPath(in: string)
        }
        guard let host = comps.host, host.count > 0 else {
            throw Error.emptyHost(in: string)
        }
        guard let scheme = comps.scheme,
            scheme == "http" || scheme == "https" else {
                throw Error.unsupportedScheme(in: string)
        }
        guard let url = comps.url else {
            throw Error.unableToCreateBaseUrl(from: string)
        }

        value = url
    }
}

try? BaseURL(string: "http://example.com").value
try? BaseURL(string: "https://example.com").value
try? BaseURL(string: "scheme://example.com").value
try? BaseURL(string: "example.com").value
try? BaseURL(string: "http://example.com/search?123=123").value
