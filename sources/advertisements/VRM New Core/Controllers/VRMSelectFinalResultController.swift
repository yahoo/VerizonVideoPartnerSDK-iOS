//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class VRMSelectFinalResultController {
    
    let dispatch: (PlayerCore.Action) -> Void
    let isFailoverEnabled: Bool
    private var firedResults = Set<VRMCore.Result>()
    
    init(isFailoverEnabled: Bool, dispatch: @escaping (PlayerCore.Action) -> Void) {
        self.dispatch = dispatch
        self.isFailoverEnabled = isFailoverEnabled
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
        guard let currentGroup = currentGroup else {
            firedResults = []
            return
        }
        guard isMaxAdSearchTimeoutReached == false,
            finalResult == nil else {
                return
        }
        
        guard firedResults.isEmpty || isFailoverEnabled else {
            dispatch(dropAd())
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
