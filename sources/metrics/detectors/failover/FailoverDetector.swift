//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    final class Failover {
        
        var adSessionID = UUID()
        
        func process(isFailover: Bool,
                     adSessionID: UUID?) -> Bool {
            guard isFailover,
                let adSessionID = adSessionID,
                self.adSessionID != adSessionID else { return false }
            self.adSessionID = adSessionID
            return true
            
        }
    }
}
