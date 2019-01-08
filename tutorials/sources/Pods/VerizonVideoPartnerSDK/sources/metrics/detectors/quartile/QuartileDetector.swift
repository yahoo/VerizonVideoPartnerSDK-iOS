//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    final class Quartile {
        
        private var sessionId: UUID?
        private var topReachedQuartile = 0
        
        struct Result {
            let newQuartile: Int
        }
        
        func process(quartile: Int?,
                     playing: Bool,
                     sessionId: UUID?,
                     isStatic: Bool = true) -> [Result] {
            guard let sessionId = sessionId else { return [] }
            
            guard isStatic else { return [] }
            
            if self.sessionId != sessionId {
                topReachedQuartile = 0
                self.sessionId = playing ? sessionId : nil
            }
            
            guard let quartile = quartile, self.sessionId != nil else { return [] }
            
            let newQuartile = min(quartile, 4)
            guard newQuartile > topReachedQuartile else { return [] }
            
            let quartilesRange = topReachedQuartile + 1 ... newQuartile
            topReachedQuartile = newQuartile
            
            var results: [Result] = []
            for quartile in quartilesRange {
                results.append(Result(newQuartile: quartile))
            }
            return results
        }
    }
}

extension Detectors.Quartile {
    func process(_ props: Player.Properties) -> [Result] {
        guard let item = props.playbackItem else { return [] }
        return process(
            quartile: item.content.time.static?.lastPlayedQuartile,
            playing: item.content.isStreamPlaying,
            sessionId: props.session.playback.id,
            isStatic: item.content.time.isStatic
        )
    }
    
    func processAd(_ props: Player.Properties) -> [Result] {
        guard let item = props.playbackItem else { return [] }
        return process(
            quartile: item.ad.time.static?.lastPlayedQuartile,
            playing: item.ad.isStreamPlaying,
            sessionId: props.session.playback.id,
            isStatic: item.ad.time.isStatic
        )
    }
}
