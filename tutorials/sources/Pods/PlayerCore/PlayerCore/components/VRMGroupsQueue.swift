//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public struct VRMGroupsQueue {
    static let initial = VRMGroupsQueue(groupsQueue: [])
    
    public let groupsQueue: [VRMCore.Group]
}

func reduce(state: VRMGroupsQueue, action: Action) -> VRMGroupsQueue {
    switch action {
    case let responseAction as VRMCore.VRMResponseAction:
        return VRMGroupsQueue(groupsQueue: responseAction.groups)
    case let currentGroupAction as VRMCore.StartGroupProcessing:
        let newGroups = state.groupsQueue.filter{ $0 != currentGroupAction.group }
        return VRMGroupsQueue(groupsQueue: newGroups)
    default: return state
    }
}
