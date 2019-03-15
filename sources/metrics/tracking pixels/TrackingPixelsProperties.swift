//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

enum TrackingPixels {
    struct Properties {
        let vrm: VRM
        struct VRM {
            let vrmResponseStatus: ResponseStatus
            enum ResponseStatus {
                case noResponse
                case response(transactionID: String?)
                
                init(response: VRMResponse?) {
                    switch response {
                    case .none:
                        self = .noResponse
                    case .some(let value):
                        self = .response(transactionID: value.transactionId)
                    }
                }
            }
            let scheduledItems: [VRMCore.Item: Set<ScheduledVRMItems.Candidate>]
            let timeoutBarrier: Double
            let completedItems: Set<VRMCore.Item>
            let timeoutedItems: Set<VRMCore.Item>
            let erroredItems: Set<VRMCore.Item>
            let responseTime: [VRMCore.Item: VRMItemResponseTime.TimeRange]
            let timeoutStatus: VRMProcessingTimeout
        }
        let trackingInfo: TrackingInfo
        struct TrackingInfo {
            let pixels: PlayerCore.AdPixels
            let vpaidEvents: [PlayerCore.VPAIDEvents]
            let progressPixels: [PlayerCore.AdVASTProgress.Pixel]
        }
        let metaInfo: MetaInfo
        struct MetaInfo {
            let adType: Ad.Metrics.PlayType
            let adVASTId: String?
            let adMetricsInfo: Ad.Metrics.Info?
            let slot: String?
            let adRequestID: String?
            let transactionId: String?
        }
        let session: Session
        struct Session {
            let isAutoplayEnabled: Bool
            let isMP4: Bool
            let isVPAID: Bool
            
            let duration: Double?
            let currentTime: Double
            
            let isAdFinished: Bool
            let isSuccessfullyCompleted: Bool
            let isForceFinished: Bool
            let isSessionCompleted: Bool
            
            let playbackSessionId: String
            let videoIndex: Int
            
            let isAdShouldBePlayed: Bool
            let isAdLoaded: Bool
            let isAdSkipped: Bool
            let playbackStarted: Bool
            
            let isMuted: Bool
            let isPlayUserAction: Bool
            let isPauseUserAction: Bool
            let isAdPresentationRequested: Bool
            
            let isAdBuffering: Bool
            let isMaxShowTimeReached: Bool
            let isOpenMeasurementActive: Bool
            let lastPlayedQuartile: Int?
            let hasDuration: Bool
            let adPlaybackError: Error?
        }
    }
}

