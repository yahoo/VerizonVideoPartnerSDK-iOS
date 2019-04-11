//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

public enum AdKill {
    case adStartTimeout
    case maxShowTime
    case none
}

func reduce(state: AdKill, action: Action) -> AdKill {
    switch action {
    case is MP4AdStartTimeout,
         is VPAIDAdStartTimeout:
        return .adStartTimeout
    case is AdMaxShowTimeout:
        return .maxShowTime
    case is ShowContent,
         is SkipAd,
         is AdPlaybackFailed,
         is VRMCore.SelectFinalResult,
         is VRMCore.NoGroupsToProcess,
         is VPAIDActions.AdError,
         is VPAIDActions.AdStopped,
         is VPAIDActions.AdSkipped,
         is VPAIDActions.AdNotSupported:
        return .none
    default: return state
    }
}
