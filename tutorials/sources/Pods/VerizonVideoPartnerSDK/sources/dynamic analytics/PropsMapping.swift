//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import JavaScriptCore
import CoreMedia
import PlayerCore

indirect enum JSøN {
    case null
    case bool(Bool)
    case string(String)
    case number(NSNumber)
    case array([JSøN])
    case object([String: JSøN])
}

extension JSøN {
    var object: Any {
        switch self {
        case .bool(let bool): return bool
        case .number(let number): return number
        case .null: return NSNull()
        case .string(let string): return string
        case .array(let array): return array.map { $0.object }
        case .object(let object):
            var mapped: [String: Any] = [:]
            object.forEach { key, value in
                mapped[key] = value.object
            }
            
            return mapped
        }
    }
}

func json(for bool: Bool?) -> JSøN {
    guard let bool = bool else { return .null }
    return JSøN.bool(bool)
}

func json(for string: String?) -> JSøN {
    guard let string = string else { return .null }
    return JSøN.string(string)
}

func json(for uint: UInt?) -> JSøN {
    guard let number = uint as NSNumber? else { return .null }
    return JSøN.number(number)
}

func json(for int: Int?) -> JSøN {
    guard let number = int as NSNumber? else { return .null }
    return JSøN.number(number)
}

func json(for int: Int64?) -> JSøN {
    guard let number = int as NSNumber? else { return .null }
    return JSøN.number(number)
}

func json(for int: Int32?) -> JSøN {
    guard let number = int as NSNumber? else { return .null }
    return JSøN.number(number)
}

func json(for int: UInt32?) -> JSøN {
    guard let number = int as NSNumber? else { return .null }
    return JSøN.number(number)
}


func json(for float: Float?) -> JSøN {
    guard let number = float as NSNumber? else { return .null }
    return JSøN.number(number)
}

func json(for float: CGFloat?) -> JSøN {
    guard let number = float as NSNumber? else { return .null }
    return JSøN.number(number)
}

func json(for double: Double?) -> JSøN {
    guard let number = double as NSNumber? else { return .null }
    return JSøN.number(number)
}

func json(for object: [String: JSøN]?) -> JSøN {
    guard let object = object else { return .null }
    return JSøN.object(object)
}

func json(for array: [JSøN]?) -> JSøN {
    guard let array = array else { return .null }
    return JSøN.array(array)
}

func json(for uuid: UUID?) -> JSøN {
    return json(for: uuid?.uuidString)
}

func json(for url: URL?) -> JSøN {
    return json(for: url?.absoluteString)
}

func json(for size: CGSize?) -> JSøN {
    guard let size = size else { return .null }
    
    return [
        "width": size.width |> json,
        "height": size.height |> json
        ] |> json
}

func json(for time: CMTime?) -> JSøN {
    guard let time = time else { return .null }
    
    return .object([
        "value": time.value |> json,
        "timescale": time.timescale |> json,
        "epoch": time.epoch |> json,
        "flags": time.flags.rawValue |> json ])
}

func json(for props: Player.Properties) -> JSøN {
    let object: [String: JSøN] = [
        "session": props.session |> json,
        "playlist": props.playlist |> json,
        "item": props.item |> json,
        "dimensions": props.dimensions |> json,
        "isAutoplayEnabled": props.isAutoplayEnabled |> json,
        "isMuted": props.isMuted |> json,
        "isPlaybackInitiated": props.isPlaybackInitiated |> json,
        "isSessionCompleted": props.isSessionCompleted |> json,
        ]
    return object |> json
}

func json(for stallRecords: [Player.Properties.PlayerSession.Playback.StallRecord]) -> JSøN {
    return stallRecords.map({ record -> JSøN in
        return record |> json
    }) |> json
}

func json(for stallRecord: Player.Properties.PlayerSession.Playback.StallRecord) -> JSøN {
    return ["duration" : stallRecord.duration |> json,
            "timestamp" : stallRecord.timestamp |> json] |> json
}

func json(for playback: Player.Properties.PlayerSession.Playback) -> JSøN {
    let object: [String : JSøN] = [
        "id": playback.id |> json,
        "duration": playback.duration |> json,
        "stallRecords": playback.stallRecords |> json,
        "intentTime": playback.intentTime |> json,
        "intentElapsedTime": playback.intentElapsedTime |> json
    ]
    return object |> json
}

func json(for session: Player.Properties.PlayerSession) -> JSøN {
    return [
        "age": session.age |> json,
        "playback": session.playback |> json
        ] |> json
}

func json(for sessionAge: Player.Properties.PlayerSession.Age) -> JSøN {
    return [
        "seconds": sessionAge.seconds |> json,
        "milliseconds": sessionAge.milliseconds |> json
        ] |> json
}

func json(for playlist: Player.Properties.Playlist) -> JSøN {
    return [
        "currentIndex": playlist.currentIndex |> json,
        "count": playlist.count |> json,
        "hasNextVideo": playlist.hasNextVideo |> json,
        "hasPrevVideo": playlist.hasPrevVideo |> json
        ] |> json
}

func json(for item: Player.Properties.PlaybackItem) -> JSøN {
    switch item {
    case .available(let available):
        return ["available": available |> json] |> json
        
    case .unavailable(let unavailable):
        return ["unavailable": unavailable |> json] |> json
    }
}

func json(for error: NSError?) -> JSøN {
    return error.map { error in
        [ "code": error.code |> json,
          "domain": error.domain |> json
            ] |> json } ?? .null
}

func json(for time: Player.Properties.PlaybackItem.Video.Time?) -> JSøN {
    guard let time = time else { return .null }
    var object: [String: JSøN]
    
    switch time {
    case .live(_): return .null
    case .`static`(let `static`): object = `static` |> json
    case .unknown: return .null
    }
    
    return object |> json
}

func json(for time: Player.Properties.PlaybackItem.Video.Time.Static) -> [String: JSøN] {
    return [
        "progress": time.progress |> json,
        "current": time.current |> json,
        "duration": time.duration |> json,
        "remaining": time.remaining |> json,
        "lastPlayedDecile": time.lastPlayedDecile |> json,
        "lastPlayedQuartile": time.lastPlayedQuartile |> json
    ]
}

func json(for bufferInfo: Player.Properties.PlaybackItem.Video.BufferInfo) -> JSøN {
    let object = [
        "progress" : bufferInfo.progress |> json,
        "time" : bufferInfo.time |> json,
        "milliseconds" : bufferInfo.milliseconds |> json
    ]
    return object |> json
}

func json(for video: Player.Properties.PlaybackItem.Video) -> JSøN {
    let object: [String: JSøN] = [
        "isBuffering": video.isBuffering |> json,
        "isLoading": video.isLoading |> json,
        "isPaused": video.isPaused |> json,
        "averageBitrate": video.averageBitrate |> json,
        "isPlaying": video.isPlaying |> json,
        "isSeekable": video.isSeekable |> json,
        "isSeeking": video.isSeeking |> json,
        "isStreamPlaying": video.isStreamPlaying |> json,
        "time": video.time |> json,
        "bufferInfo": video.bufferInfo |> json,
        "status": video.status |> json
    ]
    
    return object |> json
}

func json(for status: Player.Properties.PlaybackItem.Video.Status) -> JSøN {
    switch status {
    case .undefined:
        return ["undefined" : .null] |> json
    case .ready:
        return ["ready" : .null] |> json
    case .failed(let error):
        let object: [String : JSøN] = [
            "failed" : [
                "error" : error.localizedDescription |> json
                ] |> json
        ]
        return  object |> json
    }
}

func json(for adModel: AdCreative) -> JSøN {
    let object: [String: JSøN]
    switch adModel {
    case .mp4(let model):
        object = [
            "clickthrough": model.clickthrough |> json,
            "maintainAspectRatio": model.maintainAspectRatio |> json,
            "mediaFile": model.url |> json,
            "scalable": model.scalable |> json,
            "pixels": model.pixels |> json,
            "id": model.id |> json]
    case .vpaid(let model):
        object = [
            "adParameters": model.adParameters |> json,
            "mediaFile": model.url |> json,
            "clickthrough": model.clickthrough |> json,
            "pixels": model.pixels |> json,
            "id": model.id |> json]
    case .none: return .null
    }
    return object |> json
}

func json(for urls: [URL]) -> JSøN {
    return urls.map(json) |> json
}

func json(for adModelPixels: PlayerCore.AdPixels?) -> JSøN {
    guard let adModelPixels = adModelPixels else { return .null }
    
    let object: [String: JSøN] = [
        "clickTracking": adModelPixels.clickTracking |> json,
        "complete": adModelPixels.complete |> json,
        "creativeView": adModelPixels.creativeView |> json,
        "error": adModelPixels.error |> json,
        "firstQuartile": adModelPixels.firstQuartile |> json,
        "impression": adModelPixels.impression |> json,
        "midpoint": adModelPixels.midpoint |> json,
        "pause": adModelPixels.pause |> json,
        "resume": adModelPixels.resume |> json,
        "start": adModelPixels.start |> json,
        "thirdQuartile": adModelPixels.thirdQuartile |> json,
        ]
    
    return object |> json
}

func json(for thumbnails: PlayerCore.Model.Video.Thumbnail?) -> JSøN {
    guard let data = thumbnails?.data else { return .null }
    
    let mapped: [JSøN] = data.map { size, url in
        JSøN.object(["size": size |> json, "url": url |> json])
    }
    
    return mapped |> json
}

func json(for model: PlayerCore.Model.Video.Item) -> JSøN {
    let object: [String: JSøN] = [
        "url": model.url |> json,
        "renderer": [
            "id": model.renderer.id |> json,
            "version": model.renderer.version |> json ] |> json,
        "title": model.title |> json,
        "thumbnail": model.thumbnail |> json
    ]
    
    return object |> json
}

func json(for subtitles: Player.Properties.PlaybackItem.Video.Subtitles?) -> JSøN {
    guard let subtitles = subtitles else { return .null }
    
    switch subtitles {
    case .`internal`: return ["internal" : .null] |> json
    case .external: return .null
    }
}

func json(for model: Player.Properties.PlaybackItem.Video.Subtitles.External) -> JSøN {
    let object: [String : JSøN] = [
        "isActive": model.isActive |> json,
        "isLoaded": model.isLoaded |> json,
        "isLoading": model.isLoading |> json,
        "text": model.text |> json]
    
    return object |> json
}

func json(for mediaGroup: Player.Properties.PlaybackItem.Video.MediaGroup?) -> JSøN {
    guard let mediaGroup = mediaGroup else { return .null }
    let options = mediaGroup.options.map({ option -> JSøN in
        let object: [String: JSøN] = [
            "id" : option.id.uuidString |> json,
            "displayName" : option.displayName |> json,
            "selected" : option.selected |> json]
        return object |> json
    })
    let object: [String : JSøN] = [ "options" : options |> json ]
    
    return object |> json
}

func json(for videoAngles: (horizontal: Float, vertical: Float)?) -> JSøN {
    guard let videoAngles = videoAngles else { return .null }
    
    return [
        "horizontal": videoAngles.horizontal |> json,
        "vertical": videoAngles.vertical |> json
        ] |> json
}

func json(for available: Player.Properties.PlaybackItem.Available) -> JSøN {
    let object: [String: JSøN] = [
        "ad": available.ad |> json,
        "adModel": available.adCreative |> json,
        "content": available.content |> json,
        "hasActiveAds": available.hasActiveAds |> json,
        "isAdPlaying": available.isAdPlaying |> json,
        "isClickThroughToggled": available.isClickThroughToggled |> json,
        "isLastVideo": available.isLastVideo |> json,
        "isReplayable": available.isReplayable |> json,
        "model": available.model |> json,
        "title": available.title |> json,
        "url": available.url |> json,
        "videoAngles": available.videoAngles |> json
    ]
    
    return object |> JSøN.object
}

func json(for unavailable: Player.Properties.PlaybackItem.Unavailable) -> JSøN {
    return [ "reason": unavailable.reason |> json ] |> json
}

func json(for progress: Progress) -> JSøN {
    return [ "progress": progress.value |> json ] |> json
}
