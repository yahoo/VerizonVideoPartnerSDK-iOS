//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VRMParseItemQueue {
    static let initial = VRMParseItemQueue(candidates: [])
    
    public struct Candidate: Hashable {
        public let parentItem: VRMCore.Item
        public let id: VRMCore.ID<Candidate>
        public let vastXML: String
    }
    
    public var candidates: Set<Candidate>
}

func reduce(state: VRMParseItemQueue, action: Action) -> VRMParseItemQueue {
    switch action {
    case let parseAction as VRMCore.StartItemParsing:
        let candidate = VRMParseItemQueue.Candidate(parentItem: parseAction.originalItem,
                                                    id: VRMCore.ID(),
                                                    vastXML: parseAction.vastXML)
        var newState = state
        newState.candidates.insert(candidate)
        return newState
    default:
        return state
    }
}
