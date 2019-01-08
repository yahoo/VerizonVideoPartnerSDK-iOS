//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

extension Detectors {
    class VRMDetector {
        private var startedItems: Set<UUID> = []
        private var completedItems: Set<UUID> = []
        private var timeoutItems: Set<UUID> = []
        private var otherErrorItems: Set<UUID> = []
        
        enum Result {
            case completeRequest(Request)
            struct Request {
                let transactionID: String?
                let slot: String?
            }
            
            case startItem(StartItem)
            struct StartItem {
                let info: VRMMetaInfo
                let transactionID: String?
                let url: URL
                let requestDate: Date
            }
            
            case completeItem(CompleteItem)
            struct CompleteItem {
                let info: VRMMetaInfo
                let transactionID: String?
                let responseTime: Int
                let fillType: Ad.Metrics.FillType
                let timeoutBarrier: Int
            }
            
            case timeoutItem(TimeoutItem)
            struct TimeoutItem {
                let info: VRMMetaInfo
                let transactionID: String?
                let responseTime: Int
                let fillType: Ad.Metrics.FillType
                let timeoutBarrier: Int
            }
            
            case otherErrorItem(OtherErrorItem)
            struct OtherErrorItem {
                let info: VRMMetaInfo
                let transactionID: String?
                let responseTime: Int
                let fillType: Ad.Metrics.FillType
                let error: Error?
            }
        }
        
        private var vrmRequestID: UUID?
        init(vrmRequestID: UUID? = nil) {
            self.vrmRequestID = vrmRequestID
        }
        
        func process(state: PlayerCore.AdVRMManager) -> [Result] {
            guard let result = state.request.result else { return [] }
            var results: [Result] = []
            
            if vrmRequestID != state.request.id {
                results.append(.completeRequest(.init(transactionID: result.transactionID,
                                                      slot: result.slot)))
                vrmRequestID = state.request.id
            }
            switch result {
            case let finishResult as AdVRMManager.VRMRequest.State.FinishResult:
                results.append(contentsOf:
                    finishResult.startItems
                        .filter { startedItems.contains($0.itemID) == false }
                        .map { start in
                            startedItems.insert(start.itemID)
                            return .startItem(.init(info: start.info,
                                                    transactionID: finishResult.transactionID,
                                                    url: start.url,
                                                    requestDate: start.requestDate))
                })
                
                if let complete = finishResult.completeItem, completedItems.contains(complete.itemID) == false {
                    completedItems.insert(complete.itemID)
                    results.append(.completeItem(.init(info: complete.info,
                                                       transactionID: complete.transactionID,
                                                       responseTime: complete.responseTime,
                                                       fillType: fillType(from: complete.timeout),
                                                       timeoutBarrier: complete.requestTimeoutBarrier)))
                }
                
                results.append(contentsOf:
                    finishResult.timeoutItems
                        .filter { timeoutItems.contains($0.itemID) == false }
                        .map { timeout in
                            timeoutItems.insert(timeout.itemID)
                            return .timeoutItem(.init(info: timeout.info,
                                                      transactionID: timeout.transactionID,
                                                      responseTime: timeout.responseTime,
                                                      fillType: fillType(from: timeout.timeout),
                                                      timeoutBarrier: timeout.requestTimeoutBarrier))
                    }
                )
                
                results.append(contentsOf:
                    finishResult.otherErrorItems
                        .filter { otherErrorItems.contains($0.itemID) == false }
                        .map { otherError in
                            otherErrorItems.insert(otherError.itemID)
                            return .otherErrorItem(.init(info: otherError.info,
                                                         transactionID: otherError.transactionID,
                                                         responseTime: otherError.responseTime,
                                                         fillType: fillType(from: otherError.timeout),
                                                         error: otherError.error))
                    }
                )
            case let skipResult as AdVRMManager.VRMRequest.State.SkippedResult:
                results.append(contentsOf:
                    skipResult.startItems
                        .filter { startedItems.contains($0.itemID) == false }
                        .map { start in
                            startedItems.insert(start.itemID)
                            return .startItem(.init(info: start.info,
                                                    transactionID: skipResult.transactionID,
                                                    url: start.url,
                                                    requestDate: start.requestDate))
                })
                
                if let complete = skipResult.completeItem, completedItems.contains(complete.itemID) == false {
                    completedItems.insert(complete.itemID)
                    results.append(.completeItem(.init(info: complete.info,
                                                       transactionID: complete.transactionID,
                                                       responseTime: complete.responseTime,
                                                       fillType: fillType(from: complete.timeout),
                                                       timeoutBarrier: complete.requestTimeoutBarrier)))
                }
                
                results.append(contentsOf:
                    skipResult.timeoutItems
                        .filter { timeoutItems.contains($0.itemID) == false }
                        .map { timeout in
                            timeoutItems.insert(timeout.itemID)
                            return .timeoutItem(.init(info: timeout.info,
                                                      transactionID: timeout.transactionID,
                                                      responseTime: timeout.responseTime,
                                                      fillType: fillType(from: timeout.timeout),
                                                      timeoutBarrier: timeout.requestTimeoutBarrier))
                    }
                )
                
                results.append(contentsOf:
                    skipResult.otherErrorItems
                        .filter { otherErrorItems.contains($0.itemID) == false }
                        .map { otherError in
                            otherErrorItems.insert(otherError.itemID)
                            return .otherErrorItem(.init(info: otherError.info,
                                                         transactionID: otherError.transactionID,
                                                         responseTime: otherError.responseTime,
                                                         fillType: fillType(from: otherError.timeout),
                                                         error: otherError.error))
                    }
                )
            default: return []
            }
            
            return results
        }
    }
}

func fillType(from timeout: AdVRMManager.Timeout) -> Ad.Metrics.FillType {
    switch timeout {
    case .beforeSoft: return .beforeSoft
    case .afterSoft: return .afterSoft
    case .afterHard: return .afterHard
    }
}
