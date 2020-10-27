//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore
import CoreMedia

extension TrackingPixels.Connector {
    func process(state: PlayerCore.State, model: PlayerCore.Model) {
        guard model.playlist[state.playlist.currentIndex].available != nil else { return }
        var openMeasurementAdEvents: PlayerCore.OpenMeasurement.AdEvents?
        var openMeasurementVideoEvents: PlayerCore.OpenMeasurement.VideoEvents?
        switch state.openMeasurement {
        case .active(let adEvents, let videoEvents):
            openMeasurementAdEvents = adEvents
            openMeasurementVideoEvents = videoEvents
        case .finished(let adEvents, let videoEvents):
            openMeasurementAdEvents = adEvents
            openMeasurementVideoEvents = videoEvents
        default: break
        }
        let adType: Ad.Metrics.PlayType = perform {
            switch state.ad.currentType {
            case .preroll: return .preroll
            case .midroll: return .midroll
            }
        }
        
        let adId: String? = perform {
            guard let inline = state.vrmFinalResult.successResult ?? state.vrmFinalResult.failedResult,
                  let _ = state.vrmResponse else { return nil }
            return inline.inlineVAST.id
        }
        
        let adMetricsInfo: Ad.Metrics.Info? = perform {
            guard let inline = state.vrmFinalResult.successResult ?? state.vrmFinalResult.failedResult,
                  let _ = state.vrmResponse else { return nil }
            return Ad.Metrics.Info(metaInfo: inline.item.metaInfo)
        }
        
        let slot = state.vrmResponse?.slot
        let sessionID = state.vrmRequestStatus.request?.id
        let transactionId = state.vrmResponse?.transactionId
        
        adRequestDetector.process(with: state).flatMap { result in
            reporter.adVRMRequest(videoIndex: state.playlist.currentIndex,
                                  type: adType,
                                  sequenceNumber: state.vrmRequestStatus.requestsFired,
                                  transactionId: result.transactionId,
                                  videoViewUID: state.playbackSession.id.uuidString)
        }
        
        adEngineRequestDetector.process(state: state).forEach { result in
            reporter.adEngineRequest(videoIndex: state.playlist.currentIndex,
                                     info: result.adInfo,
                                     type: adType,
                                     transactionId: result.transactionId,
                                     videoViewUID: state.playbackSession.id.uuidString)
            reporter.adServerRequest(info: result.adInfo,
                                     videoIndex: state.playlist.currentIndex,
                                     videoViewUID: state.playbackSession.id.uuidString)
        }
        
        adEngineResponseDetector.process(state: state).forEach { result in
            reporter.adEngineResponse(videoIndex: state.playlist.currentIndex,
                                      info: result.metaInfo,
                                      type: adType,
                                      responseStatus: result.responseStatus,
                                      responseTime: result.responseTime,
                                      timeout: result.timeout,
                                      fillType: result.fillType,
                                      transactionId: transactionId,
                                      videoViewUID: state.playbackSession.id.uuidString)
        }
        
        
        struct Payload {
            let info: Ad.Metrics.Info
            let transactionID: String?
            let adID: String?
            let slot: String
            let pixels: PlayerCore.AdPixels
        }
        func engineFlow(stage: Ad.Metrics.ExecutionStage, payload: Payload) {
            reporter.adEngineFlow(videoIndex: state.playlist.currentIndex,
                                  info: payload.info,
                                  type: adType,
                                  stage: stage,
                                  width: state.viewport.dimensions?.width,
                                  height: state.viewport.dimensions?.height,
                                  autoplay: model.isAutoplayEnabled,
                                  transactionId: payload.transactionID,
                                  adId: payload.adID,
                                  videoViewUID: state.playbackSession.id.uuidString)
        }
        
        func report(with function: (Payload) -> ()) {
            func pixels() -> PlayerCore.AdPixels {
                if let pixels = state.vrmFinalResult.successResult?.inlineVAST.pixels ??
                                state.vrmFinalResult.failedResult?.inlineVAST.pixels {
                    return pixels
                } else {
                    fatalError("No pixels which are required to fire!")
                }
            }
            
            guard let adMetricsInfo = adMetricsInfo else { return }
            
            function(Payload(info: adMetricsInfo,
                             transactionID: transactionId,
                             adID: adId,
                             slot: slot ?? "",
                             pixels: pixels()))
        }
        
        /* Ad View Time Detector */ do {
            let input = Detectors.AdViewTime.Input(
                duration: state.duration.ad?.seconds,
                currentTime: state.currentTime.ad.seconds,
                isAdFinished: state.adTracker == .forceFinished,
                isSessionCompleted: state.playerSession.isCompleted,
                videoIndex: state.playlist.currentIndex,
                vvuid: state.playbackSession.id.uuidString)
            
            if let result = adViewTimeDetector.process(newInput: input) {
                guard let adId = adId,
                      let adInfo = adMetricsInfo else { return }
                reporter.adViewTime(videoIndex: result.videoIndex,
                                    info: adInfo,
                                    type: adType,
                                    videoViewUID: result.vvuid,
                                    adId: adId,
                                    transactionId: transactionId,
                                    adCurrentTime: result.time,
                                    adDuration: result.duration)
            }
        }
        /* Slot Opportunity Detector */ do {
            if let adSessionID = sessionID,
                let slot = slot {
                let playbackStarted = state.rate.adRate.stream || state.rate.contentRate.stream
                if adSlotOpportunityDetector.process( sessionID: adSessionID, playbackStarted: playbackStarted) {
                    reporter.slotOpportunity(videoIndex: state.playlist.currentIndex,
                                             slot: slot,
                                             transactionId: transactionId,
                                             width: state.viewport.dimensions?.width ?? 0,
                                             videoViewUID: state.playbackSession.id.uuidString,
                                             type: adType)
                }
            }
        }
        /* User Actions Detector */ do {
            let action: Detectors.UserActions.PossibleActions
            switch state.userActions {
            case .play: action = .play
            case .pause: action = .pause
            case .nothing: action = .nothing
            }
            let result = adUserActionsDetector.render(hasTime: state.duration.ad != nil,
                                                      action: action)
            switch result {
            case .didPlay:
                report { payload in
                    reporter.sendBeacon(urls: payload.pixels.resume)
                }
                openMeasurementVideoEvents?.resume()
            case .didPause:
                report { payload in
                    reporter.sendBeacon(urls: payload.pixels.pause)
                }
                openMeasurementVideoEvents?.pause()
            case .nothing: break
            }
        }
        
        /*Ad Max Show Time Detector*/ do {
            if adMaxShowTimerDetector.process(state: state) {
                report { payload in
                    engineFlow(stage: .killed, payload: payload)
                }
            }
        }
        /*Ad Skip Detector*/ do {
            if adSkipDetector.process(state: state) {
                report { payload in
                    reporter.sendBeacon(urls: payload.pixels.skip)
                    engineFlow(stage: .skipped, payload: payload)
                    openMeasurementVideoEvents?.skip()
                }
            }
        }
        /*Ad Progress Detector*/ do {
            let urls = adProgressDetector.process(currentTime: state.currentTime.ad.seconds,
                                                  progressPixelsArray: state.adProgress.pixels)
            reporter.sendBeacon(urls: urls)
        }
        switch state.selectedAdCreative {
        case .vpaid:
            vpaidEventsDetector.process(events: state.vpaid.events).forEach {
                switch $0 {
                case .AdScriptLoaded:
                    report { payload in
                        engineFlow(stage: .loaded, payload: payload)
                    }
                case .AdSkipped:
                    report { payload in
                        reporter.sendBeacon(urls: payload.pixels.skip)
                        engineFlow(stage: .skipped, payload: payload)
                    }
                case .AdImpression:
                    report { payload in
                        reporter.sendBeacon(urls: payload.pixels.impression)
                        engineFlow(stage: .started, payload: payload)
                        engineFlow(stage: .win, payload: payload)
                    }
                case .AdUserAcceptInvitation:
                    report { payload in
                        if payload.pixels.acceptInvitationLinear.isEmpty {
                            reporter.sendBeacon(urls: payload.pixels.acceptInvitation)
                        } else {
                            reporter.sendBeacon(urls: payload.pixels.acceptInvitationLinear)
                        }
                    }
                case .AdUserMinimize:
                    report { payload in
                        reporter.sendBeacon(urls: payload.pixels.collapse)
                    }
                case .AdUserClose:
                    report { payload in
                        if payload.pixels.closeLinear.isEmpty {
                            reporter.sendBeacon(urls: payload.pixels.close)
                        } else {
                            reporter.sendBeacon(urls: payload.pixels.closeLinear)
                        }
                    }
                case .AdVolumeChange(let volume):
                    report { payload in
                        let urls = volume == 0 ? payload.pixels.mute : payload.pixels.unmute
                        reporter.sendBeacon(urls: urls)
                    }
                case .AdStarted:
                    report { payload in
                        reporter.sendBeacon(urls: payload.pixels.creativeView)
                    }
                case .AdClickThru(_):
                    report { payload in
                        reporter.sendBeacon(urls: payload.pixels.clickTracking)
                    }
                case .AdVideoStart:
                    report { payload in
                        reporter.sendBeacon(urls: payload.pixels.start)
                        reporter.adStart(info: payload.info,
                                         videoIndex: state.playlist.currentIndex,
                                         videoViewUID: state.playbackSession.id.uuidString)
                    }
                case .AdVideoFirstQuartile:
                    report { payload in
                        reporter.sendBeacon(urls: payload.pixels.firstQuartile)
                        engineFlow(stage: .Quartile1, payload: payload)
                    }
                case .AdVideoMidpoint:
                    report { payload in
                        reporter.sendBeacon(urls: payload.pixels.midpoint)
                        engineFlow(stage: .Quartile2, payload: payload)
                        reporter.mrcAdViewGroupM(videoIndex: state.playlist.currentIndex,
                                                 info: payload.info,
                                                 type: adType,
                                                 autoplay: model.isAutoplayEnabled,
                                                 videoViewUID: state.playbackSession.id.uuidString)
                    }
                case .AdVideoThirdQuartile:
                    report { payload in
                        reporter.sendBeacon(urls: payload.pixels.thirdQuartile)
                        engineFlow(stage: .Quartile3, payload: payload)
                    }
                case .AdVideoComplete:
                    report { payload in
                        reporter.sendBeacon(urls: payload.pixels.complete)
                        engineFlow(stage: .finished, payload: payload)
                    }
                case .AdError(let error):
                    report { payload in
                    reporter.sendBeacon(urls: payload.pixels.error)
                    reporter.adEngineIssue(videoIndex: state.playlist.currentIndex,
                                           info: payload.info,
                                           type: adType,
                                           errorMessage: error.localizedDescription,
                                           stage: .load,
                                           transactionId: payload.transactionID,
                                           adId: payload.adID,
                                           videoViewUID: state.playerSession.id.uuidString)
                    }
                default: break
                }
            }
        case .mp4:
            /* Playback Cycle Detector */ do {
                let result = adPlaybackCycleDetector.process(streamPlaying: state.rate.adRate.stream,
                                                             isSuccessfullyCompleted: state.adTracker == .successfullyCompleted,
                                                             isForceFinished: state.adTracker == .forceFinished)
                switch result {
                case .start:
                    report { payload in
                        reporter.sendBeacon(urls: payload.pixels.start)
                        engineFlow(stage: .started, payload: payload)
                        reporter.adStart(info: payload.info,
                                         videoIndex: state.playlist.currentIndex,
                                         videoViewUID: state.playbackSession.id.uuidString)
                    }
                    guard let duration = state.duration.ad?.seconds else { return }
                    let volume: Float = state.mute.player ? 0 : 1
                    openMeasurementVideoEvents?.start(CGFloat(duration), CGFloat(volume))
                    
                case .complete:
                    report { payload in
                        reporter.sendBeacon(urls: payload.pixels.complete)
                        openMeasurementVideoEvents?.complete()
                        engineFlow(stage: .finished, payload: payload)
                    }
                    
                case .nothing: break
                }
            }
            
            /* Mute/Unmute Detector */ do {
                let result = muteDetector.process(isMuted: state.mute.player,
                                                  isNotFinished: state.adTracker == .unknown)
                report { payload in
                    switch result {
                    case .mute:
                        reporter.sendBeacon(urls: payload.pixels.mute)
                        openMeasurementVideoEvents?.volumeChange(0.0)
                    case .unmute:
                        reporter.sendBeacon(urls: payload.pixels.unmute)
                        openMeasurementVideoEvents?.volumeChange(1.0)
                    case .nothing: break
                    }
                }
            }

            /* Buffering Start/End Detector */ do {
                let isAdBuffering: Bool = {
                    switch state.playbackBuffering.ad {
                    case .active:
                        return true
                    case .inactive, .unknown:
                        return false
                    }
                }()
                if let openMeasurementVideoEvents = openMeasurementVideoEvents {
                    switch bufferingDetector.process(isAdBuffering: isAdBuffering) {
                    case .bufferingStart:
                        openMeasurementVideoEvents.bufferStart()
                    case .bufferingEnd:
                        openMeasurementVideoEvents.bufferFinish()
                    case .nothing: break
                    }
                }
            }
            
            /* Open Measurement Mute/Unmute Detector */ do {
                let isOMActive: Bool = {
                    guard case .active = state.openMeasurement else { return false}
                    return true
                }()
                let result = openMeasurementMuteDetector.process(
                    isMuted: state.mute.player,
                    isNotFinished: state.adTracker == .unknown,
                    isOMActive: isOMActive)
                switch result {
                case .mute:
                    openMeasurementVideoEvents?.volumeChange(0.0)
                case .unmute:
                    openMeasurementVideoEvents?.volumeChange(1.0)
                case .nothing: break
                }
            }
            
            /* Video Loading Detector */ do {
                let result = adVideoLoadingDetector.render(isLoaded: state.playbackStatus.ad == .ready,
                                                           sessionID: sessionID,
                                                           isPlaying: state.ad.currentAd.isPlaying)
                
                switch result {
                case .beginLoading:
                    report {
                        engineFlow(stage: .win, payload: $0)
                        engineFlow(stage: .loaded, payload: $0)
                    }
                    
                case .endLoading:
                    let adPosition: PlayerCore.OpenMeasurement.VideoEvents.AdPosition = {
                        switch state.ad.currentType {
                        case .preroll: return .preroll
                        case .midroll: return .midroll
                        }
                    }()
                    openMeasurementVideoEvents?.loaded(adPosition, model.isAutoplayEnabled)
                    openMeasurementAdEvents?.impressionOccurred()
                    report { payload in
                        reporter.sendBeacon(urls: payload.pixels.impression)
                        reporter.sendBeacon(urls: payload.pixels.creativeView)
                    }
                case .nothing: break
                }
            }
            
            /* Quartile Detector */ do {
                let quartile: Int? = perform {
                    guard let duration = state.duration.ad else { return nil }
                    let progress = Progress(state.currentTime.ad.seconds / duration.seconds)
                    return progress.lastPlayedQuartile
                }
                
                let hasDuration: Bool = perform {
                    guard let duration = state.duration.ad else { return false }
                    return CMTIME_IS_INDEFINITE(duration) == false
                }
                
                let result = adQuartileDetector.process(quartile: quartile,
                                                        playing: state.rate.adRate.stream,
                                                        sessionId: sessionID,
                                                        isStatic: hasDuration)
                for metric in result {
                    switch metric.newQuartile {
                    case 1:
                        report { payload in
                            reporter.sendBeacon(urls: payload.pixels.firstQuartile)
                            engineFlow(stage: .Quartile1, payload: payload)
                        }
                        openMeasurementVideoEvents?.firstQuartile()
                    case 2:
                        report { payload in
                            reporter.sendBeacon(urls: payload.pixels.midpoint)
                            engineFlow(stage: .Quartile2, payload: payload)
                            reporter.mrcAdViewGroupM(videoIndex: state.playlist.currentIndex,
                                                     info: payload.info,
                                                     type: adType,
                                                     autoplay: model.isAutoplayEnabled,
                                                     videoViewUID: state.playbackSession.id.uuidString)
                        }
                        
                        openMeasurementVideoEvents?.midpoint()
                    case 3:
                        report { payload in
                            reporter.sendBeacon(urls: payload.pixels.thirdQuartile)
                            engineFlow(stage: .Quartile3, payload: payload)
                        }
                        
                        openMeasurementVideoEvents?.thirdQuartile()
                    default: break
                    }
                }
            }
            
            /* Ad Error Detector */ do {
                adErrorDetector.process(id: sessionID ,
                                        error: perform {
                                            guard case .errored(let error) = state.playbackStatus.ad else { return nil }
                                            return error
                }).map { (issue: Detectors.AdError.Result) in
                    report { payload in
                        reporter.sendBeacon(urls: payload.pixels.error)
                        
                        reporter.adEngineIssue(videoIndex: state.playlist.currentIndex,
                                               info: payload.info,
                                               type: adType,
                                               errorMessage: issue.error.localizedDescription,
                                               stage: .load,
                                               transactionId: payload.transactionID,
                                               adId: payload.adID,
                                               videoViewUID: state.playerSession.id.uuidString)
                    }
                }
            }
            
            /* Ad Click Detector */ do {
                let result = adClickDetector.process(clicked: state.clickthrough.isPresentationRequested)
                if result {
                    report { payload in
                        reporter.sendBeacon(urls: payload.pixels.clickTracking)
                    }
                    openMeasurementVideoEvents?.click()
                }
            }
        case .none: break
        }
    }
}
