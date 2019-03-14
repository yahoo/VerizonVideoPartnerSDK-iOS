//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import PlayerCore

extension Detectors {
    final class Failover {
        
        private enum AdResult {
            case other
            case processing
            case failover
            case noAds
        }
        
        private var adSessionIDs = Set<UUID>()
        private var currentResult = AdResult.other
        
        func process(vrmResponse: VRMResponse?,
                     adSessionID: UUID?) -> Bool {
            guard let vrmResponse = vrmResponse,
                let adSessionID = adSessionID,
                adSessionIDs.contains(adSessionID) == false else {
                    currentResult = .other
                    return false
            }
            
            switch (vrmResponse.groups.isEmpty, currentResult) {
            case (true, .other):
                currentResult = .noAds
                adSessionIDs.insert(adSessionID)
                return false
            case (true, .processing):
                currentResult = .failover
                adSessionIDs.insert(adSessionID)
                return true
            default: break
            }
            currentResult = .processing
            return false
        }
    }
}
