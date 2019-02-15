//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VRMResponse {
    public let transactionId: String?
    public let slot: String
    public let groups: [VRMCore.Group]
}

func reduce(state: VRMResponse?, action: Action) -> VRMResponse? {
    switch action {
    case let adResponse as VRMCore.VRMResponseAction:
        return VRMResponse(transactionId: adResponse.transactionId,
                           slot: adResponse.slot,
                           groups: adResponse.groups)
    case is VRMCore.AdRequest:
        return nil
    default:
        return state
    }
}
