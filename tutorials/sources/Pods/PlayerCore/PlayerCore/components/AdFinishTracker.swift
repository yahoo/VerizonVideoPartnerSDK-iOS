//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct AdFinishTracker {
    public let isFinished: Bool
}

func reduce(state: AdFinishTracker, action: Action) -> AdFinishTracker {
    switch action {
    
    case is ShowAd, is AdMaxShowTimeout:
        return AdFinishTracker(isFinished: false)
        
    case is ShowContent, is SkipAd, is VRMCore.VRMResponseFetchFailed,
         is AdSkipped, is AdStopped,
         is AdStartTimeout:
        return AdFinishTracker(isFinished: true)
        
    default: return state
    }    
}
