//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

extension TrackingPixels.Properties {
    
    init(state: State, model: PlayerCore.Model) {
        vrm = TrackingPixels.Properties.vrm(state: state, model: model)
        trackingInfo = TrackingPixels.Properties.trackingInfo(state: state, model: model)
        metaInfo = TrackingPixels.Properties.metaInfo(state: state, model: model)
        session = TrackingPixels.Properties.session(state: state, model: model)
    }
    
    static func vrm(state: State, model: PlayerCore.Model) -> TrackingPixels.Properties.VRM {
        return TrackingPixels.Properties.VRM(
            vrmResponseStatus: VRM.ResponseStatus(response: state.vrmResponse),
            scheduledItems: state.vrmScheduledItems.items,
            timeoutBarrier: state.timeoutBarrier,
            completedItems: Set(state.vrmProcessingResult.processedAds.map{$0.item}),
            timeoutedItems: state.vrmTimeoutError.erroredItems,
            erroredItems: perform {
                return state.vrmRedirectError.erroredItems
                    .union(state.vrmFetchingError.erroredItems)
                    .union(state.vrmParsingError.erroredItems)
                    .union(state.vrmOtherError.erroredItems)
            },
            responseTime: state.vrmItemResponseTime.timeRangeContainer,
            timeoutStatus: state.vrmProcessingTimeout
        )
    }
    
    static func trackingInfo(state: State, model: PlayerCore.Model) -> TrackingPixels.Properties.TrackingInfo {
        return TrackingPixels.Properties.TrackingInfo(
            pixels: perform {
                if let pixels = state.vrmFinalResult.successResult?.inlineVAST.pixels ??
                    state.vrmFinalResult.failedResult?.inlineVAST.pixels {
                    return pixels
                } else {
                    fatalError("No pixels which are required to fire!")
                }
            },
            vpaidEvents: state.vpaid.events,
            progressPixels: state.adProgress.pixels
        )
    }
    
    static func metaInfo(state: State, model: PlayerCore.Model) -> TrackingPixels.Properties.MetaInfo {
        return TrackingPixels.Properties.MetaInfo(
            adType: perform {
                switch state.ad.currentType {
                case .preroll: return .preroll
                case .midroll: return .midroll
                }
            },
            adVASTId: perform {
                guard let inline = state.vrmFinalResult.successResult ?? state.vrmFinalResult.failedResult,
                    state.vrmResponse != nil else { return nil }
                return inline.inlineVAST.id
            },
            adMetricsInfo: perform {
                guard let inline = state.vrmFinalResult.successResult ?? state.vrmFinalResult.failedResult,
                    state.vrmResponse != nil else { return nil }
                return Ad.Metrics.Info(metaInfo: inline.item.metaInfo)
            },
            slot: state.vrmResponse?.slot,
            adRequestID: state.vrmRequestStatus.request?.id.uuidString,
            transactionId: state.vrmResponse?.transactionId)
    }
    
    static func session(state: State, model: PlayerCore.Model) -> TrackingPixels.Properties.Session {
        return TrackingPixels.Properties.Session(
            isAutoplayEnabled: model.isAutoplayEnabled,
            isMP4: state.selectedAdCreative.isMP4,
            isVPAID: state.selectedAdCreative.isVPAID,
            duration: state.duration.ad?.seconds,
            currentTime: state.currentTime.ad.seconds,
            isAdFinished: state.adTracker != .unknown,
            isSuccessfullyCompleted: state.adTracker == .successfullyCompleted,
            isForceFinished: state.adTracker == .forceFinished,
            isSessionCompleted: state.playerSession.isCompleted,
            playbackSessionId: state.playerSession.id.uuidString,
            videoIndex: state.playlist.currentIndex,
            isAdShouldBePlayed: state.rate.adRate.player,
            isAdLoaded: state.playbackStatus.ad == .ready,
            isAdSkipped: state.adTracker == .skipped,
            playbackStarted: state.rate.adRate.stream,
            isMuted: state.mute.player,
            isPlayUserAction: state.userActions == .play,
            isPauseUserAction: state.userActions == .pause,
            isAdPresentationRequested: state.clickthrough.isPresentationRequested,
            isAdBuffering: state.playbackBuffering.ad == .active,
            isMaxShowTimeReached: state.adKill == .maxShowTime,
            isOpenMeasurementActive: state.openMeasurement.isActive,
            lastPlayedQuartile: perform {
                guard let duration = state.duration.ad else { return nil }
                let progress = Progress(state.currentTime.ad.seconds / duration.seconds)
                return progress.lastPlayedQuartile
            },
            hasDuration: state.duration.ad != nil,
            adPlaybackError: perform {
                guard case .errored(let error) = state.playbackStatus.ad else { return nil }
                return error
            }
        )
    }
}
