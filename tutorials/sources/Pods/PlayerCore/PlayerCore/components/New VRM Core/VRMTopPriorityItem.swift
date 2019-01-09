//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public struct VRMTopPriorityItem {
    static let initial = VRMTopPriorityItem(item: nil)
    
    public let item: VRMCore.Item?
}

func reduce(state: VRMTopPriorityItem, action: Action) -> VRMTopPriorityItem {
    switch action {
    case let startGroupAction as VRMCore.StartGroupProcessing:
        return VRMTopPriorityItem(item: startGroupAction.group.items.first)
    default:
        return state
    }
}
