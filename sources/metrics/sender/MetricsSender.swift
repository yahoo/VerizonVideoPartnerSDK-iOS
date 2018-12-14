//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

enum MetricsSender {}

extension MetricsSender {
    typealias T = Action<TrackingPixels.Reporter.Item>
}

extension MetricsSender {
    struct URLSender {
        let session: URLSession
        let advertisementBaseURL: URL
        let trackingBaseURL: URL
        let trace: (URL?) -> Void
        
        func send(report: TrackingPixels.Reporter.Item) {
            let url: URL? = {
                switch report {
                case .tracking(let components):
                    return components.url(relativeTo: trackingBaseURL)
                case .advertisement(let components):
                    return components.url(relativeTo: advertisementBaseURL)
                case .thirdParty(let url): return url
                }
            }()
            trace(url)
            
            url.map(session.dataTask)?.resume()
        }
    }
}
