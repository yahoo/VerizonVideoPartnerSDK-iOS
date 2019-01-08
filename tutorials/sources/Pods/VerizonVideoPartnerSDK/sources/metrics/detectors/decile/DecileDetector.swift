//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    final class Decile {
        
        private var sessionId: UUID?
        private var topReachedDecile = 0
        
        struct Result {
            let newDecile: Int
        }
        
        func process(decile: Int?,
                     playing: Bool,
                     sessionId: UUID,
                     isStatic: Bool = true) -> [Result] {
            guard isStatic else { return [] }
            if self.sessionId != sessionId {
                topReachedDecile = 0
                self.sessionId = playing ? sessionId : nil
            }
            
            guard let decile = decile, self.sessionId != nil else { return [] }
            
            let newDecile = min(decile, 10)
            
            guard newDecile > topReachedDecile else { return [] }
            let decilesRange = topReachedDecile + 1 ... newDecile
            topReachedDecile = newDecile
            
            var results: [Result] = []
            for decile in decilesRange {
                results.append(Result(newDecile: decile))
            }
            return results
        }
        
        
        func process(_ props: Player.Properties) -> [Result] {
            guard let item = props.playbackItem else { return [] }
            return process(
                decile: item.content.time.static?.lastPlayedDecile,
                playing: item.content.isStreamPlaying,
                sessionId: props.session.playback.id,
                isStatic: item.content.time.isStatic)
        }
    }
}
