//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreMedia

public struct Duration {
    public let ad: CMTime?
    public let content: CMTime?
}

func reduce(state: Duration, action: Action) -> Duration {
    switch action {
    case is SelectVideoAtIdx:
        return Duration(ad: nil, content: nil)
        
    case let action as UpdateAdDuration:
        return Duration(ad: action.newDuration, content: state.content)
        
    case let action as UpdateContentDuration:
        return Duration(ad: state.ad, content: action.newDuration)
        
    case is SkipAd,
         is ShowContent,
         is AdStopped,
         is AdStartTimeout,
         is AdMaxShowTimeout,
         is AdError,
         is AdSkipped,
         is AdNotSupported:
        return Duration(ad: nil, content: state.content)
        
    case let action as AdDurationChange:
        return Duration(ad: action.duration, content: state.content)
    default:
        return state
    }
}
