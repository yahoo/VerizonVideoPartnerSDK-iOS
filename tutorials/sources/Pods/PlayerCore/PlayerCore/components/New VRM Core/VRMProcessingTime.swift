//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public enum VRMProcessingTime {
    static let initial = VRMProcessingTime.empty
    
    case inProgress(startAt: Date)
    case finished(startAt: Date, finishAt: Date)
    case empty
}

func reduce(state: VRMProcessingTime, action: Action) -> VRMProcessingTime {
    switch action {
    case is VRMCore.AdRequest, is AdRequest:
        return .inProgress(startAt: Date())
        
    case is ShowMP4Ad, is ShowVPAIDAd, is ShowAd:
        guard case let .inProgress(stateAt) = state else { return state }
        return .finished(startAt: stateAt, finishAt: Date())
        
    case is VRMCore.NoGroupsToProcess,
         is VRMCore.VRMResponseFetchFailed,
         is VRMCore.MaxSearchTimeout:
        return .empty
        
    default: return state
    }
}
