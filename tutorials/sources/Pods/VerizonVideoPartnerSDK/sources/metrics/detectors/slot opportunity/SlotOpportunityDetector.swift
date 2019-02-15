//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

extension Detectors {
    final class SlotOpportunity {
        var playbackInitiated = false
        var sessionID: UUID?
        
        func process(sessionID: UUID, playbackStarted: Bool) -> Bool {
            if self.sessionID != sessionID {
                self.sessionID = sessionID
                playbackInitiated = false
            }
            
            guard playbackInitiated == false,
                playbackStarted else { return false }
            
            playbackInitiated = true
            return true
        }
    }
}
