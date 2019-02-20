//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

extension Detectors {
    final class ContentPlaybackCycle {
        enum Result { case beginPlaying, endPlaying, nothing }
        
        var beginRecorded = false

        func process(streamPlaying: Bool, isFinished: Bool) -> Result {
            switch (beginRecorded, streamPlaying, isFinished) {
            case (false, true, false):
                beginRecorded = true
                return .beginPlaying
            case (true, _, true):
                beginRecorded = false
                return .endPlaying
            default: return .nothing
            }
        }
    }
}
