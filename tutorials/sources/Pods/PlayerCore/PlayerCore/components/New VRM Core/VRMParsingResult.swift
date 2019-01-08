//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VRMParsingResult {
    static let initial = VRMParsingResult(parsedVASTs: [:])
    
    var parsedVASTs: [VRMCore.Item: VRMCore.VASTModel]
}

func reduce(state: VRMParsingResult, action: Action) -> VRMParsingResult {
    
    switch action {
    case let finishParsing as VRMCore.CompleteItemParsing:
        var newState = state
        
        if let currentVASTModel = newState.parsedVASTs[finishParsing.originalItem] {
            switch(currentVASTModel, finishParsing.vastModel) {
            case let (.wrapper(currentWrapper), .wrapper(processedWrapper)):
                let mergedWrapper = processedWrapper.merge(with: currentWrapper.pixels,
                                                           and: currentWrapper.adVerifications)
                newState.parsedVASTs[finishParsing.originalItem] = .wrapper(mergedWrapper)
                return newState
            case let (.wrapper(currentWrapper), .inline(resultModel)):
                let mergedResult = resultModel.merge(with: currentWrapper.pixels,
                                                     and: currentWrapper.adVerifications)
                newState.parsedVASTs[finishParsing.originalItem] = .inline(mergedResult)
            case (.inline, _):
                fatalError("Tried to complete already completed item")
            }
        } else {
            newState.parsedVASTs[finishParsing.originalItem] = finishParsing.vastModel
        }
        
        return newState
    default:
        return state
    }
}
