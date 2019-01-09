//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

extension Detectors {
    final class AdMaxShowTimeDetector {
        private var trackedSessionId = UUID()
        private var isReported = true
        
        func process(state: PlayerCore.State) -> Bool {
            return process(adKill: state.adKill, sessionId: state.adVRMManager.request.id)
        }
        
        func process(adKill: AdKill, sessionId: UUID?) -> Bool {
            if let sessionId = sessionId, trackedSessionId != sessionId {
                trackedSessionId = sessionId
                isReported = false
            }
            
            guard adKill == .maxShowTime, isReported == false else { return false }
            
            isReported = true
            return true
        }
    }
}
