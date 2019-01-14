//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class VRMItemController {
    
    let maxRedirectCount: Int
    let dispatch: (PlayerCore.Action) -> Void
    
    private var startedCandidates = Set<ScheduledVRMItems.Candidate>()
    private var wrapperError = Set<VRMCore.Item>()
    
    init(maxRedirectCount: Int, dispatch: @escaping (PlayerCore.Action) -> Void ) {
        self.maxRedirectCount = maxRedirectCount
        self.dispatch = dispatch
    }
    
    func process(with state: PlayerCore.State) {
        process(with: state.vrmScheduledItems.items)
    }
    
    func process(with scheduledItems: [VRMCore.Item: Set<ScheduledVRMItems.Candidate>]) {
        scheduledItems.forEach { originalItem, queue in
            guard queue.count <= maxRedirectCount else {
                if wrapperError.contains(originalItem) == false {
                    wrapperError.insert(originalItem)
                    dispatch(VRMCore.tooManyIndirections(item: originalItem))
                }
                return
            }
            
            queue.subtracting(startedCandidates)
                .forEach { candidate in
                    startedCandidates.insert(candidate)
                    switch (candidate.source) {
                    case let .url(url):
                        dispatch(VRMCore.startItemFetch(originalItem: originalItem, url: url))
                    case let .vast(vastXML):
                        dispatch(VRMCore.startItemParsing(originalItem: originalItem, vastXML: vastXML))
                    }
            }
        }
    }
}
