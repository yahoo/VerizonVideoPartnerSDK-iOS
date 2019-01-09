//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public extension VRMCore {
    public static func adResponse(transactionId: String?, slot: String, groups: [Group]) -> Action {
        return VRMResponseAction(transactionId: transactionId,
                                slot: slot,
                                groups: groups)
    }
    
    public static func adResponseFetchFailed(requestID: UUID) -> Action {
        return VRMResponseFetchFailed(requestID: requestID)
    }
}
