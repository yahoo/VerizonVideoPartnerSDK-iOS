//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    final class ThreeSecondsPlayback {
        private var sessionId: UUID?
        
        struct Result {
            let currentTime: Int
            let stallDuration: Int
        }
        
        struct Input {
            let stallRecords: [Player.Properties.PlayerSession.Playback.StallRecord]
            let time: Int
            let sessionId: UUID
            let playbackDuration: TimeInterval
        }
        
        func process(input: Input?) -> Result? {
            guard let input = input else { return nil }
            guard self.sessionId != input.sessionId, input.playbackDuration >= 3 else { return nil }
            self.sessionId = input.sessionId
            
            return Result(currentTime: input.time,
                          stallDuration: totalStallDuration(from: input.stallRecords,
                                                            start: 0,
                                                            end: input.playbackDuration))
        }
    }
}

extension Detectors.ThreeSecondsPlayback.Input {
    init?(available: Player.Properties.PlaybackItem.Available?,
          stallRecords: [Player.Properties.PlayerSession.Playback.StallRecord],
          playbackDuration: TimeInterval,
          sessionId: UUID) {
        guard let available = available else { return nil }
        
        self.stallRecords = stallRecords
        self.time = available.content.time.isLive
            ? Int(playbackDuration)
            : Int(available.content.time.static?.current ?? 0.0)
        self.playbackDuration = playbackDuration
        self.sessionId = sessionId
    }
}
