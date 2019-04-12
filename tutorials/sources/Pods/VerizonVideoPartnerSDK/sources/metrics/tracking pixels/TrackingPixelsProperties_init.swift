//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

extension TrackingPixels.Properties {
    
    init(state: State, model: PlayerCore.Model) {
        metaInfo = TrackingPixels.Properties.MetaInfo(state: state, model: model)
        session = TrackingPixels.Properties.AdSession(state: state, model: model)
    }
}
extension TrackingPixels.Properties.MetaInfo {
    init(state: State, model: PlayerCore.Model) {
        adType = perform {
            switch state.ad.currentType {
            case .preroll: return .preroll
            case .midroll: return .midroll
            }
        }
        adVASTId = perform {
            guard let inline = state.vrmFinalResult.successResult ?? state.vrmFinalResult.failedResult,
                state.vrmResponse != nil else { return nil }
            return inline.inlineVAST.id
        }
        adMetricsInfo = perform {
            guard let inline = state.vrmFinalResult.successResult ?? state.vrmFinalResult.failedResult,
                state.vrmResponse != nil else { return nil }
            return Ad.Metrics.Info(metaInfo: inline.item.metaInfo)
        }
        slot = state.vrmResponse?.slot
        adRequestId = state.vrmRequestStatus.request?.id
        transactionId = state.vrmResponse?.transactionId
    }
}

extension TrackingPixels.Properties.AdSession {
    init(state: State, model: PlayerCore.Model) {
        playerDimensions = state.viewport.dimensions
        playbackSessionId = state.playbackSession.id.uuidString
        videoIndex = state.playlist.currentIndex
        isCurrentVRMGroupEmpty = state.vrmCurrentGroup.currentGroup == nil
        isVRMGroupsQueueEmpty = state.vrmGroupsQueue.groupsQueue.isEmpty
        isVRMResponseGroupsEmpty = state.vrmResponse?.groups.isEmpty == true
        isAutoplayEnabled = model.isAutoplayEnabled
    }
}
