//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VRMProcessingResult {
    static let initial = VRMProcessingResult(processedAds: [])
    
    public let processedAds: Set<VRMCore.Result>
}

func reduce(state: VRMProcessingResult, action: Action) -> VRMProcessingResult {
    
    switch action {
    case let selectResult as VRMCore.SelectInlineItem:
        let result = VRMCore.Result(item: selectResult.item,
                                    inlineVAST: selectResult.inlineVAST)
        
        return VRMProcessingResult(processedAds: state.processedAds.union([result]))
    case is VRMCore.StartGroupProcessing,
         is VRMCore.AdRequest:
        return VRMProcessingResult(processedAds: [])
    default:
        return state
    }
}
