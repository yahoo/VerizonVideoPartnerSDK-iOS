//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.hts reserved.

import Foundation
import PlayerCore

extension Detectors {
    final class AdSkipDetector {
        
        private var processed = Set<UUID>()
        
        func process(state: PlayerCore.State) -> Bool {
            return process(isSkipped: state.adTracker == .skipped,
                           id: state.vrmRequestStatus.request?.id)
        }
        
        func process(isSkipped: Bool, id: UUID?) -> Bool {
            guard let id = id,
                processed.contains(id) == false,
                isSkipped else { return false }
            processed.insert(id)
            return true
        }
    }
}
