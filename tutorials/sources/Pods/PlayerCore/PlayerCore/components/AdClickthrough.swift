//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
public struct AdClickthrough {
    public let isPresentationRequested: Bool
}

func reduce(state: AdClickthrough, action: Action) -> AdClickthrough {
    switch action {
    case is RequestClickthroughAdPresentation,
         is VPAIDActions.AdClickThru, is VPAIDActions.AdWindowOpen:
        return AdClickthrough(isPresentationRequested: true)
    case is DidHideAdClickthrough:
        return AdClickthrough(isPresentationRequested: false)
        
    default: return state
    }
}

