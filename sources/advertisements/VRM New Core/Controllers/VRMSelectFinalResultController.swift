//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class VRMSelectFinalResultController {
    
    let dispatch: (PlayerCore.Action) -> Void
    private var firedResults = Set<VRMCore.Result>()
    
    init(dispatch: @escaping (PlayerCore.Action) -> Void) {
        self.dispatch = dispatch
    }
    
    func process(with state: PlayerCore.State) {
        process(processingResults: state.vrmProcessingResult.processedAds,
                currentGroup: state.vrmCurrentGroup.currentGroup,
                isMaxAdSearchTimeoutReached: state.vrmMaxAdSearchTimeout.isReached,
                finalResult: state.vrmFinalResult.successResult,
                topPriorityItem: state.vrmTopPriorityItem.item)
    }
    
    func process(processingResults: Set<VRMCore.Result>,
                 currentGroup: VRMCore.Group?,
                 isMaxAdSearchTimeoutReached: Bool,
                 finalResult: VRMCore.Result?,
                 topPriorityItem: VRMCore.Item?) {
        guard isMaxAdSearchTimeoutReached == false,
            finalResult == nil,
            let currentGroup = currentGroup else {
                return
        }
        
        func dispatchResult(result: VRMCore.Result) {
            firedResults.insert(result)
            dispatch(VRMCore.selectFinalResult(item: result.item,
                                               inlineVAST: result.inlineVAST))
        }
        
        let filteredItems = processingResults.subtracting(firedResults)
        if let topPriorityItem = topPriorityItem {
            filteredItems
                .first { $0.item == topPriorityItem }
                .flatMap { result in
                    dispatchResult(result: result)
            }
        } else {
            for item in currentGroup.items {
                if let result = filteredItems.first(where: { $0.item == item }) {
                    dispatchResult(result: result)
                    break
                }
            }
        }
    }
}
