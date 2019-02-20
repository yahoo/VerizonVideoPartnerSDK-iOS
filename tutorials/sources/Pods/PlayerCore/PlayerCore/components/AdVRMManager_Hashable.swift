//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

extension AdVRMManager.OtherErrorItem: Hashable {
    public static func ==(lhs: AdVRMManager.OtherErrorItem, rhs: AdVRMManager.OtherErrorItem) -> Bool {
        return lhs.itemID == rhs.itemID &&
            lhs.responseTime == rhs.responseTime
    }
    
    public var hashValue: Int {
        return itemID.hashValue
    }
}
