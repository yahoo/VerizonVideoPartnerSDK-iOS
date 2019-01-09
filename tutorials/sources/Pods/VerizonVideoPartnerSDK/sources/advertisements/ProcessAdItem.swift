//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

struct VASTTagProcessor {
    let session: URLSession
    let requestTimeout: TimeInterval
    
    enum Result {
        case model(VASTModel)
        case timeout
        case parsingError
        case error(Error)
        
        init(model: VASTModel?) {
            self = model.map(Result.model) ?? Result.parsingError
        }
    }
    
    func parseTag(from string: String) -> Future<Result> {
        return Future(value: string)
            .dispatch(on: DispatchQueue.global(qos: .userInitiated))
            .map(VASTParser.parseFrom(string:))
            .map(Result.init)
    }
    
    func fetchTag(from url: URL) -> Future<Result> {
        let tagFuture = Future<(Data?, URLResponse?, Swift.Error?)> { complete in
            var request = URLRequest(url: url)
            request.timeoutInterval = requestTimeout
            self.session.dataTask(with: request, completionHandler: complete).resume()
        }
        
        return tagFuture
            .map(Network.Parse.successResponseData)
            .map(VASTParser.parseFrom(data:))
            .map { (result: VerizonVideoPartnerSDK.Result<VASTModel?>) in
                switch result {
                case .value(let value): return Result(model: value)
                case .error(let error): return Result.error(error)
                }
        }
    }
}
