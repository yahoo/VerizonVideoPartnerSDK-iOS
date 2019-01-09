//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

extension AdVRMManager.StartItem: Hashable {
    public static func ==(lhs: AdVRMManager.StartItem, rhs: AdVRMManager.StartItem) -> Bool {
        return lhs.itemID == rhs.itemID &&
            lhs.url == rhs.url &&
            lhs.requestDate == rhs.requestDate        
    }
    
    public var hashValue: Int {
        return itemID.hashValue
    }
}

extension AdVRMManager.CompleteItem: Hashable {
    public static func ==(lhs: AdVRMManager.CompleteItem, rhs: AdVRMManager.CompleteItem) -> Bool {
        return lhs.itemID == rhs.itemID &&
            lhs.responseTime == rhs.responseTime
    }
    
    public var hashValue: Int {
        return itemID.hashValue ^ responseTime.hashValue
    }
}

extension AdVRMManager.TimeoutItem: Hashable {
    public static func ==(lhs: AdVRMManager.TimeoutItem, rhs: AdVRMManager.TimeoutItem) -> Bool {
        return lhs.itemID == rhs.itemID &&
            lhs.responseTime == rhs.responseTime
    }
    
    public var hashValue: Int {
        return itemID.hashValue
    }
}

extension AdVRMManager.OtherErrorItem: Hashable {
    public static func ==(lhs: AdVRMManager.OtherErrorItem, rhs: AdVRMManager.OtherErrorItem) -> Bool {
        return lhs.itemID == rhs.itemID &&
            lhs.responseTime == rhs.responseTime
    }
    
    public var hashValue: Int {
        return itemID.hashValue
    }
}
