//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public struct VRMCurrentGroup {
    static let initial = VRMCurrentGroup(currentGroup: nil)
    
    public let currentGroup: VRMCore.Group?
}

func reduce(state: VRMCurrentGroup, action: Action) -> VRMCurrentGroup {
    switch action {
    case let currentGroupAction as VRMCore.StartGroupProcessing:
        return VRMCurrentGroup(currentGroup: currentGroupAction.group)
    case is VRMCore.FinishCurrentGroupProcessing:
        return VRMCurrentGroup(currentGroup: nil)
    case is VRMCore.AdRequest:
        return .initial
    default: return state
    }
}
