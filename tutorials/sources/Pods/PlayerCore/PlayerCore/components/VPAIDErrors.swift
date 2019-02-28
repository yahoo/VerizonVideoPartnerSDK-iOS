//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VPAIDErrors {
    public struct UniqueEventError {
        public let eventName: String
        public let eventValue: String?
    }
    
    public let abusedEvents: [UniqueEventError]
    public let javaScriptEvaluationErrors: [Error]
    public let isAdNotSupported: Bool
}

func reduce(state: VPAIDErrors, action: Action) -> VPAIDErrors {
    switch action {
    case let action as VPAIDActions.AdJavaScriptEvaluationError:
        var jsErrors = state.javaScriptEvaluationErrors
        jsErrors.append(action.error)
        return VPAIDErrors(abusedEvents: state.abusedEvents,
                           javaScriptEvaluationErrors: jsErrors,
                           isAdNotSupported: state.isAdNotSupported)
    case let action as VPAIDActions.AdUniqueEventAbuse:
        var allEvents = state.abusedEvents
        allEvents.append(.init(eventName: action.name, eventValue: action.value))
        return VPAIDErrors(abusedEvents: allEvents,
                           javaScriptEvaluationErrors: state.javaScriptEvaluationErrors,
                           isAdNotSupported: state.isAdNotSupported)
    case is VPAIDActions.AdNotSupported:
        return VPAIDErrors(abusedEvents: state.abusedEvents,
                           javaScriptEvaluationErrors: state.javaScriptEvaluationErrors,
                           isAdNotSupported: true)
    case is ShowMP4Ad,
         is ShowVPAIDAd,
         is DropAd,
         is VPAIDActions.AdStopped,
         is ShowContent,
         is SelectVideoAtIdx,
         is VRMCore.SelectFinalResult:
        return VPAIDErrors(abusedEvents: [],
                           javaScriptEvaluationErrors: [],
                           isAdNotSupported: false)
    default:
        return state
    }
}
