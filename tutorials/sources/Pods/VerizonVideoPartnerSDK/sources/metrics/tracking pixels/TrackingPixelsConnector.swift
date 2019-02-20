//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension TrackingPixels {
    struct Connector {
        
        let videoPlayDetector = Detectors.VideoPlay()
        let decileDetector = Detectors.Decile()
        let quartileDetector = Detectors.Quartile()
        let videoTimeDetector = Detectors.VideoTime()
        let playlistStatisticDetector = Detectors.PlaylistStatistic()
        let contextStartedDetector = Detectors.ContextStarted()
        let displayDetector = ExecuteOnce()
        let threeSecDetector = Detectors.ThreeSecondsPlayback()
        let heartbeatDetector = Detectors.Heartbeat()
        let intentDetector = Detectors.Intent()
        let bufferingDetector = Detectors.Buffering()
        let errorDetector = Detectors.ErrorDetector()
        let videoImpressionDetector = Detectors.VideoImpression()
        
        let vrmDetector = Detectors.VRMDetector()
        let adRequestDetector = Detectors.VRMRequestDetector()
        let adEngineRequestDetector = Detectors.AdEngineRequestDetector()
        let adEngineResponseDetector = Detectors.AdEngineResponseDetector()
        
        let adVideoLoadingDetector = Detectors.VideoLoading()
        let adQuartileDetector = Detectors.Quartile()
        let adUserActionsDetector = Detectors.UserActions()
        let adErrorDetector = Detectors.AdError()
        let adClickDetector = Detectors.AdClick()
        let adViewTimeDetector = Detectors.AdViewTime()
        let adSkipDetector = Detectors.AdSkipDetector()
        let adPlaybackCycleDetector = Detectors.AdPlaybackCycle()
        let adSlotOpportunityDetector = Detectors.SlotOpportunity()
        let muteDetector = Detectors.Mute()
        let adMaxShowTimerDetector = Detectors.AdMaxShowTimeDetector()
        
        let openMeasurementMuteDetector = Detectors.Mute()
        let vpaidEventsDetector = Detectors.VPAIDEventsDetector()
        
        let reporter: Reporter
        
        init(reporter: Reporter) { self.reporter = reporter }
        
        func process(_ props: Player.Properties) {
            
            if let brandedContent = props.playbackItem?.model.brandedContent,
               adClickDetector.process(clicked: props.playbackItem?.isClickThroughToggled == true) {
                brandedContent.tracker.map {
                    reporter.sendBeacon(urls: $0.click)
                }
            }
            
            videoPlayDetector.process(props).map { result in
                props.playbackItem?.model.brandedContent?.tracker.map {
                    reporter.sendBeacon(urls: $0.view)
                }
                reporter.videoPlay(
                    videoIndex: props.playlist.currentIndex,
                    dimensions: result.size,
                    isAutoplay: props.isAutoplayEnabled,
                    videoViewUID: props.session.playback.id.uuidString,
                    timestamp: props.session.age.milliseconds)
            }
            
            decileDetector.process(props).forEach {
                reporter.videoDecile(
                    videoIndex: props.playlist.currentIndex,
                    decileNumber: $0.newDecile,
                    isAutoplay: props.isAutoplayEnabled,
                    videoViewUID: props.session.playback.id.uuidString,
                    timestamp: props.session.age.milliseconds)
            }
            
            videoImpressionDetector.process(props).map {
                props.playbackItem?.model.brandedContent?.tracker.map {
                    reporter.sendBeacon(urls: $0.impression)
                }
                reporter.videoImpression(videoIndex: props.playlist.currentIndex,
                                         isAutoplay: props.isAutoplayEnabled,
                                         timestamp: props.session.age.milliseconds,
                                         size: $0.dimensions)
            }
            
            quartileDetector.process(props).forEach { result in
                props.playbackItem?.model.brandedContent?.tracker.map {
                    switch result.newQuartile {
                    case 1:
                        reporter.sendBeacon(urls: $0.quartile1)
                    case 2:
                        reporter.sendBeacon(urls: $0.quartile2)
                    case 3:
                        reporter.sendBeacon(urls: $0.quartile3)
                    case 4:
                        reporter.sendBeacon(urls: $0.quartile4)
                    default: break
                    }
                }
                reporter.videoQuartile(
                    videoIndex: props.playlist.currentIndex,
                    quartile: result.newQuartile,
                    isAutoplay: props.isAutoplayEnabled,
                    videoViewUID: props.session.playback.id.uuidString,
                    timestamp: props.session.age.milliseconds)
            }
            
            videoTimeDetector.process(props: props).map {
                reporter.videoTime(
                    videoIndex: $0.index,
                    isAutoplay: props.isAutoplayEnabled,
                    playedTime: $0.playTime,
                    currentProgress: $0.progress,
                    videoViewUID: $0.session.uuidString,
                    timestamp: props.session.age.milliseconds)
            }
            
            playlistStatisticDetector.process(props).map {
                reporter.videoStats(numberOfVideos: $0.videosCount,
                                    overallPlayedTime: $0.time,
                                    numberOfAds: $0.playedAds,
                                    videoIndex: props.playlist.currentIndex,
                                    videoViewUID: props.session.playback.id.uuidString)
            }
            
            contextStartedDetector.process(input:
                Detectors.ContextStarted.Input(playbackItem: props.playbackItem,
                                               sessionId: props.session.playback.id))
            {
                reporter.contextStarted(videoIndex: props.playlist.currentIndex,
                                        videoViewUID: props.session.playback.id.uuidString)
            }
            
            displayDetector.process(if: props.dimensions != nil) {
                reporter.displays(
                    size: props.dimensions,
                    videoIndex: props.playlist.currentIndex,
                    videoViewUID: props.session.playback.id.uuidString,
                    timestamp: props.session.age.milliseconds)
            }
            
            threeSecDetector.process(input: Detectors.ThreeSecondsPlayback.Input.init(
                available: props.playbackItem,
                stallRecords: props.session.playback.stallRecords,
                playbackDuration: props.session.playback.duration,
                sessionId: props.session.playback.id)).map {
                    reporter.threeSecPlayback(
                        videoIndex: props.playlist.currentIndex,
                        isAutoplay: props.isAutoplayEnabled,
                        videoViewUID: props.session.playback.id.uuidString,
                        bufferedTime: $0.stallDuration,
                        averageBitrate: props.playbackItem?.content.averageBitrate,
                        currentTime: $0.currentTime,
                        volume: props.volume)
            }
            
            heartbeatDetector.process(
                stallRecords: props.session.playback.stallRecords,
                playbackDuration: props.session.playback.duration,
                isLiveVideo: props.playbackItem?.content.time.isLive == true,
                dimensions: props.dimensions).map {
                    reporter.heartbeat(
                        videoIndex: props.playlist.currentIndex,
                        isAutoplay: props.isAutoplayEnabled,
                        videoViewUID: props.session.playback.id.uuidString,
                        width: $0.dimensions.width,
                        height: $0.dimensions.height,
                        playedTime: props.session.playback.duration,
                        bufferedTime: $0.totalStallTime,
                        averageBitrate: props.playbackItem?.content.averageBitrate,
                        volume: props.volume)
            }
        }
    }
}
