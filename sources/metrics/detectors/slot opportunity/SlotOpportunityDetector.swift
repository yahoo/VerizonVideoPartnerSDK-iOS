//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

extension Detectors {
    final class SlotOpportunity {
        var playbackInitiated = false
        var sessionID: UUID?
        
        func process(sessionID: UUID,
                     adPlaying: Bool,
                     adSkipped: Bool,
                     adFailed: Bool,
                     contentPlaying: Bool) -> Bool {
            if self.sessionID != sessionID {
                self.sessionID = sessionID
                playbackInitiated = false
            }
            
            guard playbackInitiated == false else { return false }
            switch (adSkipped, contentPlaying, adPlaying, adFailed) {
            case (true, true, _, false),
                 (_, true, _, true),
                 (false, _, true, false):
                playbackInitiated = true
                return true
                
            default: return false
            }
        }
    }
}
