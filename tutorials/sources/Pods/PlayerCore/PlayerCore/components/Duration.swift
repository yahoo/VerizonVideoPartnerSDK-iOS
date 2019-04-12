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
        
    case is DropAd,
         is ShowContent,
         is SkipAd,
         is MP4AdStartTimeout,
         is AdMaxShowTimeout,
         is VPAIDActions.AdStopped,
         is VPAIDActions.AdError,
         is VPAIDActions.AdSkipped,
         is VPAIDActions.AdNotSupported,
         is VRMCore.NoGroupsToProcess,
         is VRMCore.MaxSearchTimeout,
         is VRMCore.VRMResponseFetchFailed:
        return Duration(ad: nil, content: state.content)
        
    case let action as VPAIDActions.AdDurationChange:
        return Duration(ad: action.duration, content: state.content)
    default:
        return state
    }
}
