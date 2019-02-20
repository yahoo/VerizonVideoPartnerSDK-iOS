//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VRMMaxAdSearchTimeout {
    static let initial = VRMMaxAdSearchTimeout(isReached: false)
    
    public let isReached: Bool
}

func reduce(state: VRMMaxAdSearchTimeout, action: Action) -> VRMMaxAdSearchTimeout {
    switch action {
    case is VRMCore.MaxSearchTimeout:
        return VRMMaxAdSearchTimeout(isReached: true)
    case is VRMCore.AdRequest:
        return VRMMaxAdSearchTimeout(isReached: false)
    default: return state
    }
}
