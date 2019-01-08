//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    
    final class PlaylistStatistic {
        private var videosCount = 0 as Int
        private var adCount = 0 as Int
        
        private var contentSessionID = UUID()
        private var adSessionID = UUID()
        
        private var totalPlaybackDuration = 0 as TimeInterval
        private var playbackDuration = 0 as TimeInterval
        
        struct Result {
            let videosCount: Int
            let playedAds: Int
            let time: TimeInterval
        }
        
        func process(playing: Bool,
                     completed: Bool,
                     contentSessionID: UUID,
                     playbackDuration: TimeInterval,
                     adHasDuration: Bool,
                     adSessionID: UUID) -> Result? {
            func addContentVideo() {
                guard self.contentSessionID != contentSessionID else { return }
            
                videosCount += 1
                
                totalPlaybackDuration += self.playbackDuration
                self.contentSessionID = contentSessionID
            }
            
            if playing {
                addContentVideo()
                self.playbackDuration = playbackDuration
            }
            
            func checkAdCounter() {
                guard self.adSessionID != adSessionID, adHasDuration else { return }
                
                self.adSessionID = adSessionID
                adCount += 1
            }
            checkAdCounter()
            
            guard completed else { return nil }
            
            totalPlaybackDuration += playbackDuration
            
            return Result(videosCount: videosCount,
                          playedAds: adCount,
                          time: totalPlaybackDuration)
        }
    }
}

extension Detectors.PlaylistStatistic {
    
    func process(_ props: Player.Properties) -> Result? {
        guard let item = props.playbackItem else { return nil }

        return process(
            playing: item.content.isStreamPlaying,
            completed: props.isSessionCompleted,
            contentSessionID: props.session.playback.id,
            playbackDuration: props.session.playback.duration,
            adHasDuration: perform {
                guard item.hasActiveAds else { return false }
                return item.ad.time.static.map { $0.hasDuration } ?? false },
            adSessionID: props.adSessionID)
    }
}
