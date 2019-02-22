//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import PlayerCore
import CoreMedia
import VideoRenderer

extension Player.Properties {
    init(state: PlayerCore.State,
         model: PlayerCore.Model,
         currentTime: TimeInterval = Date().timeIntervalSince1970) {
        playlist = Playlist(hasNextVideo: state.playlist.currentIndex < model.playlist.count - 1,
                            hasPrevVideo: state.playlist.currentIndex > 0,
                            count: model.playlist.count,
                            currentIndex: state.playlist.currentIndex)
        
        dimensions = state.viewport.dimensions
        isMuted = state.mute.player
        isVPAIDMuted = state.mute.vpaid
        
        volume = state.mute.player ? 0 : 100
        let hasDimensions = dimensions != nil
        let video = model.playlist[state.playlist.currentIndex]
        let hasActiveAds: Bool = perform {
            if let ad = video.available?.ad, state.ad.playedAds.count < ad.preroll.count  {
                return true
            } else {
                switch state.ad.currentAd {
                case .empty:
                    return false
                case .play:
                    return true
                }
            }
        }
        
        func status(from state: PlayerCore.Status) -> Player.Properties.PlaybackItem.Video.Status {
            switch state {
            case .unknown:
                return .undefined
            case .ready:
                return .ready
            case .errored(let error):
                return .failed(error)
            }
        }
        
        func time(from duration: CMTime?, currentTime: CMTime?, isFinished: Bool) -> Player.Properties.PlaybackItem.Video.Time {
            guard let duration = duration else { return .unknown }
            if CMTIME_IS_INDEFINITE(duration) {
                return .live(.init(isFinished: isFinished))
            } else {
                if let currentTime = currentTime {
                    let progress = Progress(currentTime.seconds / duration.seconds)
                    return .static(.init(
                        progress: progress,
                        currentCMTime: currentTime,
                        current: currentTime.seconds,
                        duration: duration.seconds,
                        hasDuration: true,
                        remaining: duration.seconds - currentTime.seconds,
                        lastPlayedDecile: progress.lastPlayedDecile,
                        lastPlayedQuartile: progress.lastPlayedQuartile,
                        isFinished: isFinished))
                } else {
                    return .static(.init(
                        progress: 0,
                        currentCMTime: nil,
                        current: nil,
                        duration: duration.seconds,
                        hasDuration: true,
                        remaining: duration.seconds,
                        lastPlayedDecile: 0,
                        lastPlayedQuartile: 0,
                        isFinished: isFinished))
                }
            }
        }
        
        let isScreenCastingEnabled: Bool = perform {
            switch video {
            case .available(let video):
                return video.isAirPlayEnabled
            case .unavailable:
                return false
            }
        }
        
        let adSkipOffset: Int? = perform {
            guard let duration = state.duration.ad?.seconds,
                let skipOffset = state.vrmFinalResult.successResult?.inlineVAST.skipOffset else { return nil }
            let currentTime = Int(state.currentTime.ad.seconds.rounded())
            switch skipOffset {
            case .time(let value):
                guard value < Int(duration) else { return nil }
                return value - currentTime
            case .percentage(let value):
                let offset = Int(duration.rounded() / 100 * Double(value))
                guard offset < Int(duration) else { return nil }
                return offset - currentTime
            }
        }
        
        let content: PlaybackItem.Video = perform {
            let contentIsSeeking = state.interactiveSeeking.isSeekingInProgress
            let contentShouldPlay =
                state.rate.contentRate.player == true
                    && hasActiveAds == false
                    && hasDimensions
                    && contentIsSeeking == false
            let contentHasDuration = state.duration.content != nil
            let isBuffering = contentShouldPlay && state.rate.contentRate.stream == false
            return PlaybackItem.Video(
                isStreamPlaying: state.rate.contentRate.stream == true,
                isPlaying: contentShouldPlay,
                isPaused: !contentShouldPlay,
                isSeeking: contentIsSeeking,
                isSeekable: contentHasDuration,
                isLoading: contentShouldPlay && contentHasDuration,
                isBuffering: isBuffering,
                actionInitiated: userActionInitiated(hasTime: state.duration.content != nil,
                                                     shouldPlay: state.rate.contentRate.player == true,
                                                     isNotFinished: !state.playbackSession.isCompleted),
                status: status(from: state.playbackStatus.content),
                averageBitrate: state.averageBitrate.content,
                time: time(from: state.duration.content,
                           currentTime: state.currentTime.content?.time,
                           isFinished: state.playbackSession.isCompleted),
                bufferInfo: perform {
                    let bufferEnd = state.loadedTimeRanges.content.last?.end ?? CMTime.zero
                    let progress: Progress = perform {
                        guard let duration = state.duration.content?.seconds else { return 0 }
                        guard duration > 0 else { return 0 }
                        return .init(bufferEnd.seconds / duration)
                    }
                    let milliseconds: Int = perform {
                        guard bufferEnd.isValid else { return 0 }
                        let milliseconds = CMTimeMultiplyByRatio(bufferEnd, multiplier: 1000, divisor: 1).seconds
                        guard !milliseconds.isNaN else { return 0 }
                        return Int(milliseconds)
                    }
                    
                    return PlaybackItem.Video.BufferInfo(progress: progress,
                                                         time: bufferEnd,
                                                         milliseconds: milliseconds) },
                pictureInPictureMode: perform {
                    guard case .available(let available) = video, available.isPictureInPictureModeSupported  else { return .unsupported }

                    switch state.pictureInPicture {
                    case .active:
                        return .active
                    case .inactive:
                        return .possible
                    case .impossible:
                        return .impossible
                    case .unsupported:
                        return .unsupported }},
                controlsAnimationSupport: model.isControlsAnimationSupported,

                contentFullScreen: perform {
                    switch state.contentFullScreen {
                    case .active:
                        return .active
                    case .inactive:
                        return .inactive
                    }
                },
                airPlay: perform {
                    guard isScreenCastingEnabled else { return .restricted }
                    switch state.airPlay {
                    case .inactive:
                        return .inactive
                    case .restricted:
                        return .restricted
                    case .active:
                        return .active
                    case .disabled:
                        return .disabled }},
                audible: perform {
                    return .init(options: state.mediaOptions.unselectedAudibleOptions.map {
                        return PlaybackItem.Video.MediaGroup.Option(
                            id: $0.uuid,
                            displayName: $0.displayName,
                            selected: $0.uuid == state.mediaOptions.selectedAudibleOption?.uuid) })},
                legible: perform {
                    return  .internal(.init(options: state.mediaOptions.unselectedLegibleOptions.map {
                        return PlaybackItem.Video.MediaGroup.Option(
                            id: $0.uuid,
                            displayName: $0.displayName,
                            selected: $0.uuid == state.mediaOptions.selectedLegibleOption?.uuid) }))})
        }
        
        let isAdPlaying = state.ad.currentAd.isPlaying
        
        let ad: PlaybackItem.Video = perform {
            let adShouldPlay =
                state.rate.adRate.player == true
                    && isAdPlaying
                    && hasDimensions
            let adHasDuration = state.duration.ad != nil
            return PlaybackItem.Video(
                isStreamPlaying: state.rate.adRate.stream == true,
                isPlaying: adShouldPlay,
                isPaused: !adShouldPlay,
                isSeeking: false,
                isSeekable: adHasDuration,
                isLoading: adShouldPlay && adHasDuration,
                isBuffering: adShouldPlay && state.rate.adRate.stream == false,
                actionInitiated: userActionInitiated(hasTime: state.duration.ad != nil,
                                                     shouldPlay: state.rate.adRate.player == true,
                                                     isNotFinished: !state.playbackSession.isCompleted),
                status: status(from: state.playbackStatus.ad),
                averageBitrate: state.averageBitrate.ad,
                time: time(from: state.duration.ad,
                           currentTime: state.currentTime.ad,
                           isFinished: state.adTracker != .unknown),
                bufferInfo: .init(progress: 0, time: CMTime.zero, milliseconds: 0),
                pictureInPictureMode: .unsupported,
                controlsAnimationSupport: false,
                contentFullScreen: .disabled,
                airPlay: perform {
                    guard isScreenCastingEnabled else { return .restricted }
                    switch state.airPlay {
                    case .inactive:
                        return .inactive
                    case .restricted:
                        return .restricted
                    case .active:
                        return .active
                    case .disabled:
                        return .disabled
                    }
                },
                audible: .empty(),
                legible: .internal(nil))
        }
        switch video {
        case .available(let video):
            let isLastVideo = state.playlist.currentIndex == model.playlist.count - 1
            item = .available(.init(
                model: video,
                hasActiveAds: hasActiveAds,
                midrollPrefetchingOffset: model.adSettings.prefetchingOffset,
                playedAds: state.ad.playedAds,
                midrolls: state.ad.midrolls.filter {
                    state.ad.playedAds.contains($0.id) == false
                },
                adSkipOffset: adSkipOffset,
                mp4AdCreative: state.ad.mp4AdCreative,
                vpaidAdCreative: state.ad.vpaidAdCreative,
                isAdPlaying: isAdPlaying,
                content: content,
                ad: ad,
                url: video.url,
                title: video.title,
                videoAngles: perform {
                    let sphere = VideoRenderer.Renderer.Descriptor.sphere
                    guard video.renderer.id == sphere.id,
                        video.renderer.version == sphere.version else { return nil }
                    return (state.viewport.camera.horizontal, state.viewport.camera.vertical)
                },
                isClickThroughToggled: state.clickthrough.isPresentationRequested,
                vpaidClickthrough: state.vpaid.adClickthrough,
                isLastVideo: isLastVideo,
                isReplayable: isLastVideo && state.playbackSession.isCompleted && !content.isSeeking))
            
        case .unavailable(let reason):
            item = .unavailable(.init(reason: reason))
        }
        
        session = perform {
            let age = currentTime - state.playerSession.creationTime.timeIntervalSince1970
            return PlayerSession(
                age: .init(
                    seconds: age,
                    milliseconds: String(Int(age * 1000))),
                playback: .init(
                    id: state.playbackSession.id,
                    duration: state.playbackDuration.duration,
                    stallRecords: [],
                    intentTime: state.playbackSession.intentTime?.timeIntervalSince1970,
                    intentElapsedTime: perform { state.playbackSession.intentTime.map { currentTime - $0.timeIntervalSince1970 }}
                )
            )
        }
        isSessionCompleted = state.playerSession.isCompleted
        isAutoplayEnabled = model.isAutoplayEnabled
        isPlaybackInitiated = state.playerSession.isStarted
        adSessionID = state.vrmRequestStatus.request?.id ?? state.playbackSession.id
        vpaidDocument = model.vpaidSettings.document
        
    }
}
