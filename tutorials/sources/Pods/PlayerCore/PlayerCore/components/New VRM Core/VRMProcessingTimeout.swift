//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public enum VRMProcessingTimeout {
    case none
    case soft
    case hard
}

func reduce(state: VRMProcessingTimeout, action: Action) -> VRMProcessingTimeout {
    switch action {
    case is VRMCore.StartGroupProcessing,
         is VRMCore.AdRequest:
        return .none
    case is VRMCore.SoftTimeout:
        return .soft
    case is VRMCore.HardTimeout:
        return .hard
    default:
        return state
    }
}
