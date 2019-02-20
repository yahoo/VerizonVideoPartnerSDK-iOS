//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

extension VRMCore {
    struct SoftTimeout: Action {
    }
    
    struct HardTimeout: Action {
        let items: [VRMCore.Item]
        let date: Date
    }
    
    struct MaxSearchTimeout: Action {
        let requestID: UUID
    }
}
