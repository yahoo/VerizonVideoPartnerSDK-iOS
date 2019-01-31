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
        
        private var processedCandidates = Set<ScheduledVRMItems.Candidate>()
        
        func process(state: PlayerCore.State) -> [Result] {
            return process(transactionId: state.vrmResponse?.transactionId,
                           scheduledItems: state.vrmScheduledItems.items)
        }
        
        func process(transactionId: String?,
                     scheduledItems: [VRMCore.Item: Set<ScheduledVRMItems.Candidate>]) -> [Result] {
            guard scheduledItems.isEmpty == false else { return [] }
            
            struct NormalizedScheduledItem {
                let item: VRMCore.Item
                let candidate: ScheduledVRMItems.Candidate
            }
            
            return scheduledItems
                .filter { _, candidatesSet in
                    candidatesSet.isSubset(of: processedCandidates) == false
                }.reduce(into: []) { result, pair in
                       return pair.value.forEach { candidate in
                            result.append(NormalizedScheduledItem(item: pair.key, candidate: candidate))
                        }
                }.compactMap { normalized in
                    processedCandidates.insert(normalized.candidate)
                    return Result(adInfo: .init(metaInfo: normalized.item.metaInfo), transactionId: transactionId)
            }
        }
    }
    
}

