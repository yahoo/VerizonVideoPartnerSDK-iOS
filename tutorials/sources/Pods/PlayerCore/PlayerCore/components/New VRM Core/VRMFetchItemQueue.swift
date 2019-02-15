//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VRMFetchItemQueue {
    
    static let initial = VRMFetchItemQueue(candidates: [])
    
    public struct Candidate: Hashable {
        public let id = VRMCore.ID<Candidate>()
        public let parentItem: VRMCore.Item
        public let url: URL
    }
    
    public var candidates: Set<Candidate>
}

func reduce(state: VRMFetchItemQueue, action: Action) -> VRMFetchItemQueue {
    func remove(item: VRMCore.Item ) -> VRMFetchItemQueue {
        let filteredCandidates = state.candidates
            .filter { $0.parentItem != item }
        return VRMFetchItemQueue(candidates: Set(filteredCandidates))
    }
    
    switch action {
    case let fetchAction as VRMCore.StartItemFetch:
        let candidate = VRMFetchItemQueue.Candidate(parentItem: fetchAction.originalItem,
                                                    url: fetchAction.url)
        var newState = state
        newState.candidates.insert(candidate)
        return newState
    case let parsingAction as VRMCore.StartItemParsing:
        return remove(item: parsingAction.originalItem)
    case let fetchingError as VRMCore.FetchingError:
        return remove(item: fetchingError.originalItem)
        
    case is VRMCore.AdRequest,
         is VRMCore.HardTimeout:
        return .initial
    default:
        return state
    }
}
