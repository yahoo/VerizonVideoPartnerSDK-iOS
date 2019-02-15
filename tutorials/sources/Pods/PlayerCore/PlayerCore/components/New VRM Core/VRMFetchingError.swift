//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VRMFetchingError {
    public let erroredItems: Set<VRMCore.Item>
}

func reduce(state: VRMFetchingError, action: Action) -> VRMFetchingError {
    switch action {
    case let fetchError as VRMCore.FetchingError:
        return VRMFetchingError(erroredItems: state.erroredItems.union([fetchError.originalItem]))
    case is VRMCore.AdRequest:
        return VRMFetchingError(erroredItems:[])
    default:
        return state
    }
}
