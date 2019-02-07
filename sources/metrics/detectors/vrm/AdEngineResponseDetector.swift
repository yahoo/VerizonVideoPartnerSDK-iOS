//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

extension Detectors {
    final class AdEngineResponseDetector {
        
        struct Result {
            let metaInfo: Ad.Metrics.Info
            let responseStatus: Ad.Metrics.ResponseStatus?
            let responseTime: UInt?
            let timeout: Int?
            let fillType: Ad.Metrics.FillType?
        }
        
        private var trackedItems = Set<VRMCore.Item>()
        
        func process(state: PlayerCore.State) -> [Result] {
            let erroredItems = state.vrmRedirectError.erroredItems
                .union(state.vrmFetchingError.erroredItems)
                .union(state.vrmParsingError.erroredItems)
            return process(timeoutBarrier: state.timeoutBarrier,
                           completedItems: Set(state.vrmProcessingResult.processedAds.map{$0.item}),
                           timeoutedTimes: state.vrmTimeoutError.erroredItems,
                           otherErrors: erroredItems,
                           responseTime: state.vrmItemResponseTime.timeRangeContainer,
                           timeoutStatus: state.vrmProcessingTimeout)
        }
        
        func process(timeoutBarrier: Double,
                     completedItems: Set<VRMCore.Item>,
                     timeoutedTimes: Set<VRMCore.Item>,
                     otherErrors: Set<VRMCore.Item>,
                     responseTime: [VRMCore.Item: VRMItemResponseTime.TimeRange],
                     timeoutStatus: VRMProcessingTimeout) -> [Result] {
            return completedItems
                .union(timeoutedTimes)
                .union(otherErrors)
                .subtracting(trackedItems)
                .map { item in
                    trackedItems.insert(item)
                    let responseStatus: Ad.Metrics.ResponseStatus = perform {
                        if completedItems.contains(item) {
                            return .yes
                        } else if timeoutedTimes.contains(item) {
                            return .timeout
                        } else if otherErrors.contains(item) {
                            return .no
                        } else {
                            fatalError("Imposible case. We are iterating over items from one of that set. Item should be present in one of them")
                        }
                    }
                    
                    let responseTime: UInt? = perform {
                        guard let timeRange = responseTime[item],
                            let finishAt = timeRange.finishAt else {
                                return nil
                        }
                        return UInt(finishAt.timeIntervalSince(timeRange.startAt) * 1000)
                    }
                    
                    let fillType: Ad.Metrics.FillType = perform {
                        switch timeoutStatus {
                        case .none: return .beforeSoft
                        case .soft: return .afterSoft
                        case .hard: return .afterHard
                        }
                    }
                    
                    let timeout: Int? = perform {
                        guard responseStatus == .timeout else { return nil }
                        return Int(timeoutBarrier * 1000)
                    }
                    
                    return Result(metaInfo: .init(metaInfo: item.metaInfo),
                                  responseStatus: responseStatus,
                                  responseTime: responseTime,
                                  timeout: timeout,
                                  fillType: fillType)
            }
        }
    }
}
