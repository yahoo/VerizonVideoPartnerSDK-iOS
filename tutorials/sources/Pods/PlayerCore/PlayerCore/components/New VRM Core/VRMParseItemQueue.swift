//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VRMParseItemQueue {
    static let initial = VRMParseItemQueue(candidates: [])
    
    public struct Candidate: Hashable {
        public let id = VRMCore.ID<Candidate>()
        public let parentItem: VRMCore.Item
        public let vastXML: String
    }
    
    public var candidates: Set<Candidate>
}

func reduce(state: VRMParseItemQueue, action: Action) -> VRMParseItemQueue {
    func remove(item: VRMCore.Item ) -> VRMParseItemQueue {
        let filteredCandidates = state.candidates
            .filter { $0.parentItem != item }
        return VRMParseItemQueue(candidates: Set(filteredCandidates))
    }
    
    switch action {
    case let parseAction as VRMCore.StartItemParsing:
        let candidate = VRMParseItemQueue.Candidate(parentItem: parseAction.originalItem,
                                                    vastXML: parseAction.vastXML)
        var newState = state
        newState.candidates.insert(candidate)
        return newState
    case let finishParsing as VRMCore.CompleteItemParsing:
        return remove(item: finishParsing.originalItem)
    case let failedParsing as VRMCore.ParsingError:
        return remove(item: failedParsing.originalItem)
    case is VRMCore.AdRequest:
        return .initial
    default:
        return state
    }
}
