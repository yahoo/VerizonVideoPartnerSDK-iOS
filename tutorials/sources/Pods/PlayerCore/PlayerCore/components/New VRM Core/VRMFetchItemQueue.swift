//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VRMFetchItemQueue {
    
    static let initial = VRMFetchItemQueue(candidates: [])
    
    public struct Candidate: Hashable {
        public let parentItem: VRMCore.Item
        public let id: VRMCore.ID<Candidate>
        public let url: URL
    }
    
    public var candidates: Set<Candidate>
}

func reduce(state: VRMFetchItemQueue, action: Action) -> VRMFetchItemQueue {
    switch action {
    case let fetchAction as VRMCore.StartItemFetch:
        let candidate = VRMFetchItemQueue.Candidate(parentItem: fetchAction.originalItem,
                                                         id: VRMCore.ID(),
                                                         url: fetchAction.url)
        var newState = state
        newState.candidates.insert(candidate)
        return newState
    default:
        return state
    }
}
