//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore
import CoreMedia

extension TrackingPixels {
    
    struct AdProps {
        struct VRM {
            let requestId: UUID?
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
            let erroredItems: Set<VRMCore.Item>
            let timeoutBarrier: Double
            let completedItems: Set<VRMCore.Item>
            let timeoutedTimes: Set<VRMCore.Item>
            let otherErrors: Set<VRMCore.Item>
            let responseTime: [VRMCore.Item: VRMItemResponseTime.TimeRange]
            let timeoutStatus: VRMProcessingTimeout
        }
        
        //basic
        let adType: Ad.Metrics.PlayType
        let adId: String?
        let adMetricsInfo: Ad.Metrics.Info?
        let slot: String?
        let sessionID: UUID?
        let transactionId: String?
        
        struct Session {
            //ad view time
            let duration: Double?
            let currentTime: Double
            let isAdFinished: Bool
            let isSessionCompleted: Bool
            let videoIndex: Int
            let playbackSessionId: String
            //slotop
            let playbackStarted: Bool
            //user action
            let playbackUserAction: Detectors.UserActions.PossibleActions
            //max show time
            let isMaxShowTimeReached: Bool
            //ad skip
            let isAdSkipped: Bool
            //ad progress
            let progressPixels: [PlayerCore.AdVASTProgress.Pixel]
            //playback cycle
            let isAdPlaying: Bool
            let isSuccessfullyCompleted: Bool
            let isForceFinished: Bool
            let volume: Float
            //mute
            let isNotFinished: Bool
            let isMuted: Bool
            //buffering
            let isAdBuffering: Bool
            //open measurement
            let isOpenMeasurementActive: Bool
            //video lodaing
            let isAdShouldBePlayed: Bool
            let isAdLoaded: Bool
            let isAutoplayEnabled: Bool
            //quartile
            let lastPlayedQuartile: Int
            let hasDuration: Bool
            //ad error
            let adPlaybackError: Error?
            //ad click
            let isAdPresentationRequested: Bool
            //vpaid actions
            let trackingEvents: [PlayerCore.VPAIDEvents]
        }
    }
}
