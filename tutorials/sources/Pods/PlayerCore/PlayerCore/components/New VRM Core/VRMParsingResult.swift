//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VRMParsingResult {
    static let initial = VRMParsingResult(parsedVASTs: [:])
    
    public struct Result: Hashable {
        public let id = VRMCore.ID<Result>()
        public let vastModel: VRMCore.VASTModel
    }
    
    public var parsedVASTs: [VRMCore.Item: Result]
}

func reduce(state: VRMParsingResult, action: Action) -> VRMParsingResult {
    
    switch action {
    case let finishParsing as VRMCore.CompleteItemParsing:
        var newState = state
        
        if let currentVASTModel = newState.parsedVASTs[finishParsing.originalItem]?.vastModel {
            switch(currentVASTModel, finishParsing.vastModel) {
            case let (.wrapper(currentWrapper), .wrapper(processedWrapper)):
                let mergedWrapper = processedWrapper.merge(pixels: currentWrapper.pixels,
                                                           verifications: currentWrapper.adVerifications,
                                                           adProgress: currentWrapper.adProgress)
                newState.parsedVASTs[finishParsing.originalItem] = .init(vastModel: .wrapper(mergedWrapper))
                return newState
            case let (.wrapper(currentWrapper), .inline(resultModel)):
                let mergedResult = resultModel.merge(pixels: currentWrapper.pixels,
                                                     verifications: currentWrapper.adVerifications,
                                                     adProgress: currentWrapper.adProgress)
                newState.parsedVASTs[finishParsing.originalItem] = .init(vastModel: .inline(mergedResult))
            case (.inline, _):
                fatalError("Tried to complete already completed item")
            }
        } else {
            newState.parsedVASTs[finishParsing.originalItem] = .init(vastModel: finishParsing.vastModel)
        }
        
        return newState
    case is VRMCore.AdRequest:
        return .initial
    default:
        return state
    }
}
