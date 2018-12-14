//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension URLSession {
    func dataFuture(with request: URLRequest) -> Future<(Data?, URLResponse?, Error?)> {
        return Future { complete in
            self.dataTask(with: request, completionHandler: complete).resume()
        }
    }
    
    func dataFuture(with url: URL) -> Future<(Data?, URLResponse?, Error?)> {
        return Future { complete in
            self.dataTask(with: url, completionHandler: complete).resume()
        }
    }
}

extension OVPSDK {
    public struct Provider {
        public var url: URL = URL(string: "https://api.onesdk.aol.com/config")!
        public var context: Context = Context.current
        public var session = URLSession.init(configuration: .ephemeral)
        
        public static let `default` = Provider()
        
        public func getConfiguration() -> Future<Result<Configuration>> {
            do {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: context.json, options: [])
                
                let future: Future<Result<OVPSDK.Configuration>> = session.dataFuture(with: request)
                    .map(Network.Parse.successResponseData |> Network.Parse.json)
                    .map { (json: Any) in try json |> parse }
                
                return future
                
            } catch let error {
                return Future(value: .error(error))
            }
        }
        
        public func getSDK() -> Future<Result<OVPSDK>> {
            return getConfiguration().map(OVPSDK.init)
        }
    }
}
