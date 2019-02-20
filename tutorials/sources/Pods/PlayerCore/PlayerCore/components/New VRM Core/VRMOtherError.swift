//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VRMOtherError {
    public let erroredItems: Set<VRMCore.Item>
}

func reduce(state: VRMOtherError, action: Action) -> VRMOtherError {
    switch action {
    case let otherError as VRMCore.OtherError:
        return VRMOtherError(erroredItems: state.erroredItems.union([otherError.item]))
    case is VRMCore.AdRequest:
        return VRMOtherError(erroredItems:[])
    default:
        return state
    }
}
