//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
public struct PlaybackBuffering {
    public let content: Status
    public let ad: Status
    
    public enum Status {
        case unknown
        case active
        case inactive
    }
}

func reduce(state: PlaybackBuffering, action: Action) -> PlaybackBuffering {
    switch action {
    case is ContentPlaybackBufferingActive:
        return PlaybackBuffering(content: .active, ad: state.ad)
    case is AdPlaybackBufferingActive:
        return PlaybackBuffering(content: state.content, ad: .active)
    case is ContentPlaybackBufferingInactive:
        return PlaybackBuffering(content: .inactive, ad: state.ad)
    case is AdPlaybackBufferingInactive,
         is AdMaxShowTimeout,
         is AdStartTimeout,
         is AdPlaybackFailed,
         is ShowContent:
        return PlaybackBuffering(content: state.content, ad: .inactive)
    case is SelectVideoAtIdx:
        return PlaybackBuffering(content: .unknown, ad: .unknown)
    case is ContentPlaybackFailed:
        return PlaybackBuffering(content: .unknown, ad: state.ad)
    default: return state
    }
}
