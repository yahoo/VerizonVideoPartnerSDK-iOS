//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    final class Intent {
        
        private var sessionId: UUID?
        
        func process(isVideoAvailable: Bool,
                     isPlaybackInitiated: Bool,
                     sessionId: UUID,
                     onDetect: Action<Void>) {
            guard isVideoAvailable else { return }
            guard isPlaybackInitiated else { return }
            guard self.sessionId != sessionId else { return }
            
            self.sessionId = sessionId
            
            onDetect(())
        }
    }
}
