//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension OVP {
    /// SDK Network typealias.
    public typealias Network = OathVideoPartnerSDK.Network
}

/// Model with all network information
/// that is required for metrics and video providing.
public enum Network {
    /// Describes common network errors
    public enum Error: Swift.Error {
        /// Error due to connection problems.
        case connection(networkError: Swift.Error)
        
        /// Invalid status codes.
        case serverResponse(httpResponse: HTTPURLResponse, content: String)
        
        /// Wrapper for all parsing and format validation errors
        case parsing(Swift.Error)
    }
}

extension Network { enum Request {} }
extension Network.Request {
    struct Info {
        let url: URL
        let userAgent: String?
    }
    
    static func from(info: Info) -> URLRequest {
        var request = URLRequest(url: info.url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let userAgent = info.userAgent {
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        }
        
        return request
    }
}

extension Network { enum Parse {} }
extension Network.Parse {
    typealias Parser<From, To> = (From) throws -> To
    
    struct JSONError: Error {
        let json: String
        let message: String
    }
    
    static func successResponseData(data: Data?,
                                    urlResponse: URLResponse?,
                                    error: Error?) throws -> Data {
        if let error = error {
            throw Network.Error.connection(networkError: error)
        }
        
        guard let response = urlResponse as? HTTPURLResponse else {
            fatalError("Unexpected response: \(String(describing: urlResponse))")
        }
        
        guard let data = data else {
            fatalError("Data cannot be nil with response: \(response)")
        }
        
        guard 200...299 ~= response.statusCode else {
            throw Network.Error.serverResponse(httpResponse: response,
                                               content: string(data: data))
        }
        
        return data
    }
    
    static func string(data: Data) -> String {
        guard let string = String(data: data, encoding: .utf8) else {
            fatalError("Cannot parse string from data: \(data)")
        }
        
        return string
    }
    
    static func json(data: Data) throws -> Any {
        do {
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch let error {
            enum Error: Swift.Error {
                case invalidJSONFormat(jsonError: Swift.Error, jsonString: String)
            }
            throw Error.invalidJSONFormat(jsonError: error,
                                          jsonString: string(data: data))
        }
    }

    static func jsonArray(object: Any) throws -> [JSON] {
        enum Error: Swift.Error {
            case expectArrayOfObjectsAsJSON(object: Any)
            case emptyArrayOfObjectAtTopLevel
        }
        
        guard let jsons = object as? [JSON] else {
            throw Error.expectArrayOfObjectsAsJSON(object: object)
        }
        
        guard jsons.count > 0 else {
            throw Error.emptyArrayOfObjectAtTopLevel
        }
        
        return jsons
    }
    
    static func jsonObject(object: Any) throws -> JSON {
        guard let result = object as? JSON else {
            enum Error: Swift.Error { case expectJSONObject(inObject: Any) }
            throw Error.expectJSONObject(inObject: object)
        }
    
        return result
    }
    
    static func jsonSingleObject(jsons: [JSON]) throws -> JSON {
        
        guard jsons.count == 1 else {
            enum Error: Swift.Error { case expectArrayWithOneElement }
            throw Error.expectArrayWithOneElement
        }
        
        return jsons[0]
    }
}

extension Network {
    static func get(from request: URLRequest) -> Future<Result<String>> {
        let networkCall = Future<(Data?, URLResponse?, Swift.Error?)> { complete in
            URLSession.shared.dataTask(with: request, completionHandler: complete).resume()
        }
        
        return networkCall.map(Parse.successResponseData |> Parse.string)
    }
    
    static func get(from url: URL) -> Future<Result<String>> {
        return get(from: URLRequest(url: url))
    }
}

