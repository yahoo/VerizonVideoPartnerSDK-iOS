//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public enum AdFinishTracker {
    case forceFinished
    case successfullyCompleted
    case skipped
    case unknown
}

func reduce(state: AdFinishTracker, action: Action) -> AdFinishTracker {
    switch action {
    
    case is VRMCore.AdRequest:
        return .unknown
    case is DropAd, is VRMCore.VRMResponseFetchFailed,
         is VPAIDActions.AdSkipped, is VPAIDActions.AdStopped,
         is MP4AdStartTimeout, is AdMaxShowTimeout,
         is VRMCore.NoGroupsToProcess, is VRMCore.MaxSearchTimeout:
        return .forceFinished
    case is ShowContent:
        return .successfullyCompleted
    case is SkipAd:
        return .skipped
    default: return state
    }    
}
