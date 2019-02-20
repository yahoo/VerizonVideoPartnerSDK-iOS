//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension VideoProvider { enum Parse {} }
extension VideoProvider.Parse {
    
    static func response(from json: JSON,
                         for type: VideoProvider.TrackingType) throws -> VideoProvider.Response {
        return try VideoProvider.Response(
            videos: (json.parse("videos") as [JSON]).map(videoResponse),
            tracking: (json.parse("tracking"), type) |> tracking,
            autoplay: json.parse("autoplay"),
            features: json.parse("features") |> features,
            adSettings: json.parse("adSettings") |> adSettings
        )
    }
    
    static func tracking(from json: JSON,
                         for type: VideoProvider.TrackingType) throws -> VideoProvider.Response.Tracking {
        let context: JSON = try json.parse("context")
        switch type {
        case .native: return .native(try native(from: context))
        case .javascript: return .javascript(context)
        }
    }
    
    static func native(from json: JSON) throws -> VideoProvider.Response.Tracking.Native {
        return try VideoProvider.Response.Tracking.Native(
            adURL: json.parse("adUrl") |> url,
            trkURL: json.parse("trkUrl") |> url,
            pid: json.parse("pid"),
            appID: json.parse("app_id"),
            bcid: json.parse("bcid"),
            uuid: json.parse("uuid"),
            siteSection: json.parse("sitesection"),
            playerVersion: json.parse("playerVersion"),
            playerType: json.parse("playerType"),
            videoIds: json.parse("vid"),
            playlistId: json.parse("bid"),
            sessionId: json.parse("sessionID"),
            referringURLString: json.parse("referringURL"),
            platformSupport: json.parse("platformSupport"),
            vcdn: json.parse("mediaFileHosts"),
            apid: json.parse("apid"),
            vcid: json.parse("vcid"),
            mpid: json.parse("mpid")
        )
    }
    
    static func features(from json: JSON) throws -> VideoProvider.Response.Features {
        return try .init(isControlsAnimationEnabled: json.parse("isControlsAnimationEnabled"),
                         isVPAIDAllowed: json.parse("isVPAIDAllowed"),
                         isOpenMeasurementEnabled: json.parse("isOpenMeasurementEnabled"),
                         isNewVRMCoreEnabled: json.parse("isNewVRMCoreEnabled"))
    }
    
    static func adSettings(from json: JSON) throws -> VideoProvider.Response.AdSettings {
        return try .init(prefetchingOffset: json.parse("prefetchingOffset"),
                         softTimeout: json.parse("softTimeout"),
                         hardTimeout: json.parse("hardTimeout"),
                         startTimeout: json.parse("startTimeout"),
                         maxSearchTime: json.parse("maxSearchTime"),
                         maxDuration: json.parse("maxShowTime"),
                         maxVASTWrapperRedirectCount: json.parse("maxVASTWrapperRedirectCount"))
    }
    
    static func videoResponse(from json: JSON) throws -> VideoProvider.Response.VideoResponse {
        if let json: JSON = json.parse("video") {
            return .video(try video(from: json))
        }
        if let json: JSON = json.parse("restricted") {
            return .restricted(reason: try json.parse("reason"))
        }
        if let json: JSON = json.parse("missing") {
            return .missing(reason: try json.parse("reason"))
        }
        if let json: JSON = json.parse("invalid") {
            return .invalid(reason: try json.parse("reason"))
        }
        if let json: JSON = json.parse("missingRenderer") {
            return .missingRenderer(try renderer(from: json))
        }
        
        struct UnknownResponseType: Error {
            let json: JSON
        }
        
        throw UnknownResponseType(json: json)
    }
    
    
    static func video(from json: JSON) throws -> VideoProvider.Response.Video {
        return try VideoProvider.Response.Video(
            id: json.parse("id"),
            url: url(from: json.parse("url")),
            title: json.parse("title"),
            thumbnails: (json.parse("thumbnails") as [JSON]).map(thumbnail),
            renderer: renderer(from: json.parse("renderer")),
            pods: (json.parse("pods") as [JSON]).map(pod),
            isScreenCastingEnabled: json.parse("isScreenCastingEnabled"),
            isPictureInPictureEnabled: json.parse("isPictureInPictureEnabled"),
            brandedContent: brandedContent(from: json.parse("brandedContent"))
        )
    }
    
    static func url(from string: String) throws -> URL {
        enum Error: Swift.Error {
            case cannotParseURL(String)
            case missedSchema(String)
            
        }
        
        guard let url = URL(string: string) else { throw Error.cannotParseURL(string) }
        guard url.scheme != nil else { throw Error.missedSchema(string) }
        
        return url
    }
    
    static func thumbnail(from json: JSON) throws -> VideoProvider.Response.Thumbnail {
        return try VideoProvider.Response.Thumbnail(
            width: json.parse("width"),
            height: json.parse("height"),
            url: url(from: json.parse("url"))
        )
    }
    
    static func renderer(from json: JSON) throws -> VideoProvider.Response.Video.Descriptor {
        return try VideoProvider.Response.Video.Descriptor(
            id: json.parse("id"),
            version: json.parse("version")
        )
    }
    
    static func pod(from json: JSON) throws -> VideoProvider.Response.Pod {
        return try VideoProvider.Response.Pod(
            time: podTime(from: json),
            url: json.parse("url") |> url
        )
    }
    
    static func podTime(from json: JSON) throws -> VideoProvider.Response.PodTime {
        struct UnableToDetectTime: Error { let value: Any }
        
        if let string = json.parse("time") as String? {
            if string == "preroll" { return .preroll }
            if string == "postroll" { return .postroll }
            throw UnableToDetectTime(value: json)
        } else if let seconds = json.parse("time") as Int? {
            return .seconds(seconds)
        }
        throw UnableToDetectTime(value: json)
    }
    
    static func brandedContentTracker(from json: JSON?) throws -> VideoProvider.Response.Video.BrandedContent.Tracker? {
        guard let json = json else { return nil }
        
        func urls(by key: String) throws -> [URL] {
            guard let urlCandidates = json.parse(key) as [String]? else { return [] }
            return try urlCandidates.map(url)
        }
        
        return try VideoProvider.Response.Video.BrandedContent.Tracker(impression: urls(by: "impression"),
                                                                       view: urls(by: "view"),
                                                                       click: urls(by: "click"),
                                                                       quartile1: urls(by: "quartile1"),
                                                                       quartile2: urls(by: "quartile2"),
                                                                       quartile3: urls(by: "quartile3"),
                                                                       quartile4: urls(by: "quartile4"))
    }
    
    static func brandedContent(from json: JSON?) throws -> VideoProvider.Response.Video.BrandedContent? {
        guard let json = json else { return nil }
        
        return try VideoProvider.Response.Video.BrandedContent(advertisementText: json.parse("advertisementText"),
                                                               clickUrl: try? json.parse("clickUrl") |> url,
                                                               tracker: json.parse("trackers") |> brandedContentTracker)
    }
}
