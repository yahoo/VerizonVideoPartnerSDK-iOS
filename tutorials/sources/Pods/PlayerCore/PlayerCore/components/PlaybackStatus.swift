//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public enum Status: Hashable {
    case unknown
    case ready
    case errored(NSError)
}

func reduceAd(state: Status, action: Action) -> Status {
    switch action {
    case is AdPlaybackReady:
        return .ready
        
    case let action as AdPlaybackFailed:
        return .errored(action.error)
        
    case is SelectVideoAtIdx:
        return .unknown
        
    default:
        return state
    }
}

func reduceContent(state: Status, action: Action) -> Status {
    switch action {
    case is ContentPlaybackReady:
        return .ready
        
    case let action as ContentPlaybackFailed:
        return .errored(action.error)
        
    case is SelectVideoAtIdx:
        return .unknown
        
    default:
        return state
    }
}

public struct PlaybackStatus {
    public let content: Status
    public let ad: Status
}

public func reduce(state: PlaybackStatus, action: Action) -> PlaybackStatus {
    return PlaybackStatus(
        content: reduceContent(state: state.content, action: action),
        ad: reduceAd(state: state.ad, action: action)
    )
}
