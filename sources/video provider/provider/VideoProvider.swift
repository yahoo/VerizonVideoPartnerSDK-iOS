//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public struct VideoProvider {
    public let session: URLSession
    public let url: URL
    public let context: JSON

    public enum TrackingType { case native, javascript }
    public let trackingType: TrackingType
    
    public init(session: URLSession, url: URL, context: JSON, trackingType: TrackingType) {
        self.session = session
        self.url = url
        self.context = context
        self.trackingType = trackingType
    }
    
    enum Request {
        static func makeRequestFrom(url: URL, json: JSON) throws -> URLRequest {
            let data = try JSONSerialization.data(withJSONObject: json)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return request
        }
        
        static func makeJSONFrom(ids: JSON,
                                 context: JSON,
                                 siteSection: String,
                                 autoplay: Bool,
                                 extra: JSON) -> JSON {
            var player = ids
            if !extra.isEmpty {
                player["extra"] = extra
            }
            player["sitesection"] = siteSection
            player["autoplay"] = autoplay
            player["context"] = context
            
            return ["player": player]
        }
    }
    
    public func getVideosBy(ids: JSON,
                            siteSection: String,
                            autoplay: Bool,
                            extra: JSON = [:]) -> Future<Result<Response>> {
        let json = Request.makeJSONFrom(ids: ids, 
                                        context: context, 
                                        siteSection: siteSection, 
                                        autoplay: autoplay, 
                                        extra: extra)
        
        var jsonResponseString: String?
        
        func mapParseError(error: Error) -> Error {
            guard let jsonResponseString = jsonResponseString else { return error }
            return Network.Parse.JSONError(json: jsonResponseString,
                                           message: error.localizedDescription)
        }
        
        return Future(value: (url, json))
            .map(Request.makeRequestFrom(url:json:))
            .then(session.dataFuture)
            .map(Network.Parse.successResponseData)
            .onSuccess(call: { jsonResponseString = Network.Parse.string(data: $0) })
            .map(Network.Parse.json)
            .map(Network.Parse.jsonObject)
            .map({ ($0, self.trackingType) })
            .map(VideoProvider.Parse.response)
            .mapError(mapParseError)
    }
    
    public func getVideosBy(videoIDs: [String],
                            siteSection: String,
                            autoplay: Bool,
                            extra: JSON = [:]) -> Future<Result<Response>> {
        return getVideosBy(ids: ["videoIds": videoIDs],
                           siteSection: siteSection,
                           autoplay: autoplay,
                           extra: extra)
    }
    
    public func getVideosBy(playlistID: String,
                            siteSection: String,
                            autoplay: Bool, 
                            extra: JSON = [:]) -> Future<Result<Response>> {
        return getVideosBy(ids: ["playlistId": playlistID],
                           siteSection: siteSection,
                           autoplay: autoplay, 
                           extra: extra)
    }
}
