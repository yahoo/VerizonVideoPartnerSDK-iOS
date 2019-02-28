//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

public enum AdKill {
    case adStartTimeout
    case maxShowTime
    case none
}

func reduce(state: AdKill, action: Action) -> AdKill {
    switch action {
    case is AdStartTimeout:
        return .adStartTimeout
    case is AdMaxShowTimeout:
        return .maxShowTime
    case is ShowContent,
         is SkipAd,
         is AdPlaybackFailed,
         is VPAIDActions.AdError,
         is VPAIDActions.AdStopped,
         is VPAIDActions.AdSkipped,
         is VPAIDActions.AdNotSupported:
        return .none
    default: return state
    }
}
