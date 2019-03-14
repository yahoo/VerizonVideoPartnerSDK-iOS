//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import PlayerCore

extension Detectors {
    final class Failover {
        
        private enum AdResult {
            case none
            case failover
        }
        
        private var adSessionIDs = Set<UUID>()
        
        func process(vrmResponse: VRMResponse?,
                     currentGroup: VRMCore.Group?,
                     groupQueue: [VRMCore.Group],
                     adSessionID: UUID?) -> Bool {
            guard let vrmResponse = vrmResponse,
                let adSessionID = adSessionID,
                adSessionIDs.contains(adSessionID) == false else {
                    return false
            }
            func finishProcessing(with result: AdResult) -> Bool {
                self.adSessionIDs.insert(adSessionID)
                return result == .failover
            }
            guard vrmResponse.groups.isEmpty == false else {
                return finishProcessing(with: .none)
            }
            guard currentGroup == nil,
                groupQueue.isEmpty else {
                    return false
            }
            return finishProcessing(with: .failover)
        }
    }
}
