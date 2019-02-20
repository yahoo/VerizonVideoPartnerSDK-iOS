//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct ScheduledVRMItems {
    static let initial = ScheduledVRMItems(items: [:])
    
    public struct Candidate: Hashable {
        public let id = VRMCore.ID<Candidate>()
        public let source: VRMCore.Item.Source
    }
    
    public var items: [VRMCore.Item: Set<Candidate>]
}

func reduce(state: ScheduledVRMItems, action: Action) -> ScheduledVRMItems {
    switch action {
    case let startGroupAction as VRMCore.StartGroupProcessing:
        var newState = state
        startGroupAction.group.items.forEach { item in
            newState.items[item] = Set(arrayLiteral: .init(source:item.source))
        }
        return newState
        
    case let unwrapAction as VRMCore.UnwrapItem:
        var newState = state
        let candidate = ScheduledVRMItems.Candidate(source: .url(unwrapAction.url))
        newState.items[unwrapAction.item]?.insert(candidate)
        return newState
    case is VRMCore.AdRequest:
        return .initial
    default:
        return state
    }
}
