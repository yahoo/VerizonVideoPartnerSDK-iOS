//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VRMParsingError {
    public let erroredItems: Set<VRMCore.Item>
}

func reduce(state: VRMParsingError, action: Action) -> VRMParsingError {
    switch action {
    case let parsingError as VRMCore.ParsingError:
        return VRMParsingError(erroredItems: state.erroredItems.union([parsingError.originalItem]))
    case is VRMCore.AdRequest:
        return VRMParsingError(erroredItems:[])
    default:
        return state
    }
}
