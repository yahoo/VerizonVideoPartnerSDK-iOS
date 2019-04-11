//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import PlayerCore

extension Detectors {
    final class Failover {
        
        private var adSessionIds = Set<UUID>()
        
        func process(isVRMResponseGroupsEmpty: Bool,
                     isCurrentVRMGroupEmpty: Bool,
                     isVRMGroupsQueueEmpty: Bool,
                     adSessionId: UUID?) -> Bool {
            guard let adSessionId = adSessionId,
                adSessionIds.contains(adSessionId) == false else {
                    return false
            }
            guard isVRMResponseGroupsEmpty == false,
                isCurrentVRMGroupEmpty,
                isVRMGroupsQueueEmpty else { return false }
            self.adSessionIds.insert(adSessionId)
            return true
        }
    }
}
