//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

extension Detectors {
    final class AdPlaybackCycle {
        enum Result { case start, complete, nothing }
        
        var isStartRecorded = false

        func process(streamPlaying: Bool, isSuccessfullyCompleted: Bool, isForceFinished: Bool) -> Result {
            guard isForceFinished == false else {
                isStartRecorded = false
                return .nothing
            }
            switch (isStartRecorded, streamPlaying, isSuccessfullyCompleted) {
            case (false, true, false):
                isStartRecorded = true
                return .start
            case (true, _, true):
                isStartRecorded = false
                return .complete
            default: return .nothing
            }
        }
    }
}
