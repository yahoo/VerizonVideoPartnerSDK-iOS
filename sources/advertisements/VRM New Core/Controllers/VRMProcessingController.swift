//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class VRMProcessingController {
    
    let maxRedirectCount: Int
    let dispatch: (PlayerCore.Action) -> Void
    
    private var dispatchedResults = Set<VRMParsingResult.Result>()
    
    init(maxRedirectCount: Int,dispatch: @escaping (PlayerCore.Action) -> Void) {
        self.maxRedirectCount = maxRedirectCount
        self.dispatch = dispatch
    }
    
    func process(with state: PlayerCore.State) {
        process(parsingResultQueue: state.vrmParsingResult.parsedVASTs,
                scheduledVRMItems: state.vrmScheduledItems.items,
                isMaxAdSearchTimeoutReached: state.vrmMaxAdSearchTimeout.isReached)
    }
    
    func process(parsingResultQueue: [VRMCore.Item: VRMParsingResult.Result],
                 scheduledVRMItems: [VRMCore.Item: Set<ScheduledVRMItems.Candidate>],
                 isMaxAdSearchTimeoutReached: Bool) {
        guard isMaxAdSearchTimeoutReached == false else {
            return
        }
        
        parsingResultQueue
            .filter { _, result in
                dispatchedResults.contains(result) == false
            }.forEach { item, result in
                
                if case .inline(let vast) = result.vastModel {
                    dispatch(VRMCore.selectInlineVAST(item: item, inlineVAST: vast))
                } else if case .wrapper(let wrapper) = result.vastModel {
                    guard let count = scheduledVRMItems[item]?.count else {
                        assertionFailure("try to unwrap item, which wasn't started")
                        return
                    }
                    
                    if (count + 1) < maxRedirectCount {
                        dispatch(VRMCore.unwrapItem(item: item, url: wrapper.tagURL))
                    } else {
                        dispatch(VRMCore.tooManyIndirections(item: item))
                    }
                }
                
                dispatchedResults.insert(result)
        }
    }
}
