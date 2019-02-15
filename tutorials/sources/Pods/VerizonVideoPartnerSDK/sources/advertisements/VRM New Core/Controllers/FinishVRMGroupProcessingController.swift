//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class FinishVRMGroupProcessingController {
    let dispatch: (PlayerCore.Action) -> ()
    private var finishedGroupIds = Set<VRMCore.Group.ID>()
    private var triedItems = Set<VRMCore.Item>()
    private var isMaxAdSearchTimeTracked = false
    
    
    init(dispatch: @escaping (PlayerCore.Action) -> ()) {
        self.dispatch = dispatch
    }
    
    func process(with state: PlayerCore.State) {
        let allErroredItems = state.vrmTimeoutError.erroredItems
            .union(state.vrmFetchingError.erroredItems)
            .union(state.vrmParsingError.erroredItems)
            .union(state.vrmRedirectError.erroredItems)
            .union(state.vrmOtherError.erroredItems)
        let processedItems = Set(state.vrmProcessingResult.processedAds.map({$0.item}))
        
        process(with: state.vrmProcessingTimeout,
                isMaxSearchTimeReached: state.vrmMaxAdSearchTimeout.isReached,
                currentGroup: state.vrmCurrentGroup.currentGroup,
                erroredItems: allErroredItems,
                processedItems: processedItems,
                finalResult: state.vrmFinalResult.successResult)
    }
    
    func process(with timeout: VRMProcessingTimeout,
                 isMaxSearchTimeReached: Bool,
                 currentGroup: VRMCore.Group?,
                 erroredItems: Set<VRMCore.Item>,
                 processedItems: Set<VRMCore.Item>,
                 finalResult: VRMCore.Result?) {
        guard let currentGroup = currentGroup,
            finishedGroupIds.contains(currentGroup.id) == false else {
            return
        }
        
        func finishGroup() {
            finishedGroupIds.insert(currentGroup.id)
            dispatch(VRMCore.finishCurrentGroupProcessing())
        }
        
        guard isMaxSearchTimeReached == false else {
            if isMaxAdSearchTimeTracked == false {
                isMaxAdSearchTimeTracked = true
                finishGroup()
            }
            return
        }
        
        isMaxAdSearchTimeTracked = false
        
        if let finalResult = finalResult {
            triedItems.insert(finalResult.item)
        }
        
        let triedAllProcessedItemsAfterHardTimeout = timeout == .hard &&
                                                     finalResult == nil &&
                                                     processedItems.isSubset(of: triedItems)
        let allItemsInGroupAlreadyFailed = Set(currentGroup.items).isSubset(of: erroredItems)
        
        if triedAllProcessedItemsAfterHardTimeout || allItemsInGroupAlreadyFailed {
            finishGroup()
        }
    }
}
