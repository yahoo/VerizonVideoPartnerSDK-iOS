//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

extension Detectors {
    
    final class AdEngineRequestDetector {
        
        struct Result {
            let adInfo: Ad.Metrics.Info
            let transactionId: String?
        }
        
        private var processedItems = Set<VRMCore.Item>()
        
        func process(state: PlayerCore.State) -> [Result] {
            return process(transactionId: state.vrmResponse?.transactionId,
                           scheduledItems: state.vrmScheduledItems.items)
        }
        
        func process(transactionId: String?,
                     scheduledItems: [VRMCore.Item: Set<ScheduledVRMItems.Candidate>]) -> [Result] {
            guard scheduledItems.isEmpty == false else { return [] }
            
            return Set(scheduledItems.keys)
                .subtracting(processedItems)
                .compactMap { item in
                    processedItems.insert(item)
                    return Result(adInfo: Ad.Metrics.Info(metaInfo: item.metaInfo),
                                  transactionId: transactionId)
            }
        }
    }
}

