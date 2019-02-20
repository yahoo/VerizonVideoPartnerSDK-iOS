//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VRMRedirectError {
    public let erroredItems: Set<VRMCore.Item>
}

func reduce(state: VRMRedirectError, action: Action) -> VRMRedirectError {
    switch action {
    case let redirectError as VRMCore.TooManyIndirections:
        return VRMRedirectError(erroredItems: state.erroredItems.union([redirectError.item]))
    case is VRMCore.AdRequest:
        return VRMRedirectError(erroredItems:[])
    default:
        return state
    }
}
