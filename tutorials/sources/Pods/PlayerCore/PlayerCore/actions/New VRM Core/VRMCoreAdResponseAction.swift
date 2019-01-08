//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension VRMCore {
    struct VRMResponseAction: Action {
        let transactionId: String?
        let slot: String
        let groups: [Group]
    }
    
    struct VRMResponseFetchFailed: Action {
        let requestID: UUID
    }
}
