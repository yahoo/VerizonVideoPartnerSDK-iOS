//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VRMProcessingTime {
    static let initial = VRMProcessingTime(status: .empty)
    
    public let status: BufferingStatus
}

func reduce(state: VRMProcessingTime, action: Action) -> VRMProcessingTime {
    switch action {
    case is VRMCore.AdRequest:
        return VRMProcessingTime(status: .inProgress(startAt: Date()))
        
    case is ShowMP4Ad, is ShowVPAIDAd:
        guard case let .inProgress(stateAt) = state.status else { return state }
        return VRMProcessingTime(status: .finished(startAt: stateAt, finishAt: Date()))
        
    case is VRMCore.NoGroupsToProcess,
         is VRMCore.VRMResponseFetchFailed,
         is VRMCore.MaxSearchTimeout:
        return VRMProcessingTime(status: .empty)
        
    default: return state
    }
}
