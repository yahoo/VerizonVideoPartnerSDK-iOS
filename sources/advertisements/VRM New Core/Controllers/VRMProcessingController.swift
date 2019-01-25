//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class VRMProcessingController {
    
    let dispatch: (PlayerCore.Action) -> Void
    private var dispatchedResults = Set<VRMParsingResult.Result>()
    
    init(dispatch: @escaping (PlayerCore.Action) -> Void) {
        self.dispatch = dispatch
    }
    
    func process(with state: PlayerCore.State) {
        process(parsingResultQueue: state.vrmParsingResult.parsedVASTs,
                currentGroup: state.vrmCurrentGroup.currentGroup,
                timeout: state.vrmProcessingTimeout)
    }
    
    func process(parsingResultQueue: [VRMCore.Item: VRMParsingResult.Result],
                 currentGroup: VRMCore.Group?,
                 timeout: VRMProcessingTimeout) {
        parsingResultQueue
            .filter { _, result in
                dispatchedResults.contains(result) == false
            }.forEach { item, result in
                
                if currentGroup == nil || currentGroup?.items.contains(item) == false || timeout == .hard {
                    dispatch(VRMCore.timeoutError(item: item))
                } else if case .inline(let vast) = result.vastModel {
                    dispatch(VRMCore.selectInlineVAST(item: item, inlineVAST: vast))
                } else if case .wrapper(let wrapper) = result.vastModel {
                    dispatch(VRMCore.unwrapItem(item: item, url: wrapper.tagURL))
                }
                
                dispatchedResults.insert(result)
        }
    }
}
