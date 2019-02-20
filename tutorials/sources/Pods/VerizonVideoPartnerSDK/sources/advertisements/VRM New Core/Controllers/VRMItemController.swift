//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class VRMItemController {
    
    let dispatch: (PlayerCore.Action) -> Void
    
    private var startedCandidates = Set<ScheduledVRMItems.Candidate>()
    private var wrapperError = Set<VRMCore.Item>()
    
    init(dispatch: @escaping (PlayerCore.Action) -> Void ) {
        self.dispatch = dispatch
    }
    
    func process(with state: PlayerCore.State) {
        process(with: state.vrmScheduledItems.items,
                isMaxAdSearchTimeReached: state.vrmMaxAdSearchTimeout.isReached)
    }
    
    func process(with scheduledItems: [VRMCore.Item: Set<ScheduledVRMItems.Candidate>],
                 isMaxAdSearchTimeReached: Bool) {
        guard isMaxAdSearchTimeReached == false else {
            return
        }
        
        scheduledItems.forEach { originalItem, queue in
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
