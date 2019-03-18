//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

enum TrackingPixels {
    struct Properties {
        let metaInfo: MetaInfo
        let session: AdSession
        
        struct MetaInfo {
            let adType: Ad.Metrics.PlayType
            let adVASTId: String?
            let adMetricsInfo: Ad.Metrics.Info?
            let slot: String?
            let adRequestId: UUID?
            let transactionId: String?
        }
        struct AdSession {
            let playerDimensions: CGSize?
            let playbackSessionId: String
            let videoIndex: Int
            let isCurrentVRMGroupEmpty: Bool
            let isVRMGroupsQueueEmpty: Bool
            let isVRMResponseGroupsEmpty: Bool
            let isAutoplayEnabled: Bool
        }
    }
}

