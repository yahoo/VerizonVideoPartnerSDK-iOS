//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class FinishVRMGroupProcessingController {
    let dispatch: (PlayerCore.Action) -> ()
    private var finishedGroupIds = Set<VRMCore.Group.ID>()
    
    init(dispatch: @escaping (PlayerCore.Action) -> ()) {
        self.dispatch = dispatch
    }
    
    func process(with state: PlayerCore.State) {
        let allErroredItems = state.vrmTimeoutError.erroredItems
            .union(state.vrmFetchingError.erroredItems)
            .union(state.vrmParsingError.erroredItems)
            .union(state.vrmRedirectError.erroredItems)
        let processedItems = Set(state.vrmParsingResult.parsedVASTs.keys.map({$0}))
        
        process(with: state.vrmProcessingTimeout,
                isMaxSearchTimeReached: state.vrmMaxAdSearchTimeout.isReached,
                currentGroup: state.vrmCurrentGroup.currentGroup,
                erroredItems: allErroredItems,
                processedItems: processedItems)
    }
    
    func process(with timeout: VRMProcessingTimeout,
                 isMaxSearchTimeReached: Bool,
                 currentGroup: VRMCore.Group?,
                 erroredItems: Set<VRMCore.Item>,
                 processedItems: Set<VRMCore.Item>) {
        guard let currentGroup = currentGroup,
            finishedGroupIds.contains(currentGroup.id) == false else {
                return
        }
        
        let allItemFinished = Set(currentGroup.items).isSubset(of: erroredItems.union(processedItems))
        if timeout == .hard ||
            isMaxSearchTimeReached ||
            allItemFinished {
            finishedGroupIds.insert(currentGroup.id)
            dispatch(VRMCore.finishCurrentGroupProcessing())
        }
    }
}
