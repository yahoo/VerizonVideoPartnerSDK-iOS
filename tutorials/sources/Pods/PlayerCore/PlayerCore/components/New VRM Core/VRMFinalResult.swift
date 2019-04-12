//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public enum VRMFinalResult: Equatable {
    static let initial = VRMFinalResult.empty
    
    case empty
    case selected(result: VRMCore.Result)
    case failed(result: VRMCore.Result)
    
    public var successResult: VRMCore.Result? {
        guard case let .selected(result) = self else { return nil }
        return result
    }
    
    public var failedResult: VRMCore.Result? {
        guard case let .failed(result) = self else { return nil }
        return result
    }
}

func reduce(state: VRMFinalResult, action: Action) -> VRMFinalResult {
    switch action {
    case let finalResult as VRMCore.SelectFinalResult:
        return .selected( result: .init(item: finalResult.item,
                                        inlineVAST: finalResult.inlineVAST))
    case is AdPlaybackFailed,
         is MP4AdStartTimeout,
         is VPAIDAdStartTimeout,
         is VPAIDActions.AdError,
         is VPAIDActions.AdNotSupported:
        guard let result = state.successResult else { return state }
        return .failed(result: result)
         
    case is VRMCore.AdRequest:
        return .empty
    default: return state
    }
}
