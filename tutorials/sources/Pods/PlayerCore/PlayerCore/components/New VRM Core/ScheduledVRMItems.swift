//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct ScheduledVRMItems {
    static let initial = ScheduledVRMItems(items: [])
    
    public let items: Set<VRMCore.Item>
}

func reduce(state: ScheduledVRMItems, action: Action) -> ScheduledVRMItems {
    switch action {
    case let startGroupAction as VRMCore.StartGroupProcessing:
        let allScheduledItems = state.items.union(startGroupAction.group.items)
        return ScheduledVRMItems(items: allScheduledItems)
    default:
        return state
    }
}
