//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

extension VRMCore {
    public static func softTimeoutReached() -> Action {
        return SoftTimeout()
    }
    
    public static func hardTimeoutReached(items: [VRMCore.Item], date: Date = Date()) -> Action {
        return HardTimeout(items: items, date: date)
    }
    
    public static func maxSearchTimeoutReached(requestID: UUID) -> Action {
        return MaxSearchTimeout(requestID: requestID)
    }
}
