//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    final class ContextStarted {
        
        struct Input {
            let contentIsStreamPlaying: Bool
            let adIsStreamPlaying: Bool
            let sessionId: UUID
        }
        
        private var sessionId: UUID?
        
        func process(input: Input?, onDetect: Action<Void>) {
            guard let input = input else { return }
            guard input.contentIsStreamPlaying || input.adIsStreamPlaying else { return }
            guard self.sessionId != input.sessionId else { return }
            
            self.sessionId = input.sessionId
            
            onDetect(())
        }
    }
}

extension Detectors.ContextStarted.Input {
    init?(playbackItem: Player.Properties.PlaybackItem.Available?, sessionId: UUID) {
        guard let playbackItem = playbackItem else { return nil }
        contentIsStreamPlaying = playbackItem.content.isStreamPlaying
        adIsStreamPlaying = playbackItem.ad.isStreamPlaying
        self.sessionId = sessionId
    }
    
    init(isStreamPlaying: Bool, sessionId: UUID) {
        contentIsStreamPlaying = isStreamPlaying
        adIsStreamPlaying = isStreamPlaying
        self.sessionId = sessionId
    }
}
