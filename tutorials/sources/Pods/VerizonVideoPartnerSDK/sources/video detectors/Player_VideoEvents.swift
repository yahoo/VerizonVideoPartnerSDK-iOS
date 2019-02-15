//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import PlayerCore

/// Represents video playback events.
public struct PlaybackEvents {
    let beginLoading: Action<PlayerCore.Model.Video.Item>
    let endLoading: Action<PlayerCore.Model.Video.Item>
    
    let beginPlaying: Action<PlayerCore.Model.Video.Item>
    let endPlaying: Action<PlayerCore.Model.Video.Item>
    
    let didPause: Action<Void>
    let didPlay: Action<Void>
    
    /// Quartile representation of video play progress.
    public enum Quartile: Int {
        /// 25% or first quartile
        case first = 1
        /// 50% or second quartile
        case second = 2
        /// 75% or third quartile
        case third = 3
        /// 100% or fourth quartile
        case fourth = 4
    }
    let didPlayedQuartile: Action<Quartile>
    
    /// - parameter beginLoading: Video loading began.
    /// - parameter endLoading: Video loading ended.
    /// - parameter beginPlaying: Video began playing.
    /// - parameter endPlaying: Video ended playing.
    /// - parameter didPause: Video paused.
    /// - parameter didPlay: Video started playing
    /// - parameter didPlayedQuartile: Video played quartile
    // swiftlint:disable function_parameter_count
    public init(
        beginLoading: @escaping Action<PlayerCore.Model.Video.Item>,
        endLoading: @escaping Action<PlayerCore.Model.Video.Item>,
        beginPlaying: @escaping Action<PlayerCore.Model.Video.Item>,
        endPlaying: @escaping Action<PlayerCore.Model.Video.Item>,
        didPause: @escaping Action<Void>,
        didPlay: @escaping Action<Void>,
        didPlayedQuartile: @escaping Action<Quartile>
        ) {
            self.beginLoading = beginLoading
            self.endLoading = endLoading
            self.beginPlaying = beginPlaying
            self.endPlaying = endPlaying
            self.didPause = didPause
            self.didPlay = didPlay
            self.didPlayedQuartile = didPlayedQuartile
    }
    // swiftlint:enable function_parameter_count
}

extension Player {
    
    /// Add video events
    /// - parameter playbackEvents: Playback events struct with callbacks.
    /// - returns: Dispose lambda to be called when events no longer needed.
    @available(*, deprecated: 2.12)
    public func addVideoEvents(playbackEvents: PlaybackEvents) -> Player.PropsObserverDispose {
        return addVideoEvents(on: .main, playbackEvents: playbackEvents)
    }
    
    /// Add video events
    /// - parameter queue: Dispatch queue on which observer props will be delivered.
    /// - parameter playbackEvents: Playback events struct with callbacks.
    /// - returns: Dispose lambda to be called when events no longer needed.
    public func addVideoEvents(on queue: DispatchQueue, playbackEvents: PlaybackEvents) -> Player.PropsObserverDispose {
        let videoLoadingProcess = Detectors.VideoLoading().renderContent
        let videoActionsProcess = Detectors.VideoActions()
        let quartileDetector = Detectors.Quartile()
        func quartileDetectorProcess(_ props: Player.Properties) {
            quartileDetector.process(props).forEach {
                let quartile = PlaybackEvents.Quartile(rawValue: $0.newQuartile)!
                playbackEvents.didPlayedQuartile(quartile)
            }
        }
        let playbackCycle = Detectors.ContentPlaybackCycle()
        func playbackCycleProcess(_ props: Player.Properties) {
            guard let item = props.playbackItem else { return }
            let result = playbackCycle.process(
                streamPlaying: item.content.isStreamPlaying,
                isFinished: perform {
                    switch item.content.time {
                    case .live(let live): return live.isFinished
                    case .`static`(let `static`): return `static`.isFinished
                    case .unknown: return false
                    }
            })
            switch result {
            case .beginPlaying: playbackEvents.beginPlaying(item.model)
            case .endPlaying: playbackEvents.endPlaying(item.model)
            case .nothing: break
            }
        }
        
        return addObserver(on: queue) { props in
            guard let item = props.playbackItem else { return }
            /* Video Loading Detector */ do {
                switch videoLoadingProcess(props) {
                case .beginLoading: playbackEvents.beginLoading(item.model)
                case .endLoading: playbackEvents.endLoading(item.model)
                case .nothing: break
                }
            }
            
            playbackCycleProcess(props)
            
            /* Video Actions Detector */ do {
                switch videoActionsProcess.renderContent(props) {
                case .didPlay: playbackEvents.didPlay(())
                case .didPause: playbackEvents.didPause(())
                case .nothing: break
                }
            }
            
            quartileDetectorProcess(props)
        }
    }
}
