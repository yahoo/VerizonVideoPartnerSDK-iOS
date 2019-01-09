//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import CoreMedia

extension Detectors {
    final class AdViewTime {
        
        var isProcessed = false
        var timePlayed: Double = 0
        
        struct Result {
            let duration: Double
            let time: Double
            let videoIndex: Int
            let vvuid: String
        }
        
        var input = Input(duration: nil,
                          currentTime: 0,
                          isAdFinished: false,
                          isSessionCompleted: false,
                          videoIndex: 0,
                          vvuid: "")
        struct Input {
            let duration: Double?
            let currentTime: Double
            let isAdFinished: Bool
            let isSessionCompleted: Bool
            let videoIndex: Int
            let vvuid: String
        }
        
        func process(newInput: Input) -> Result? {
            if newInput.duration != nil, !newInput.isAdFinished, !isProcessed {
                isProcessed = true
                self.input = newInput
            }
            guard isProcessed, let duration = self.input.duration else { return nil }
            if newInput.currentTime > timePlayed { timePlayed = newInput.currentTime }
            guard newInput.isAdFinished
                || newInput.isSessionCompleted
                || newInput.duration == nil else { return nil }
            let result = Result(duration: duration,
                                time: timePlayed,
                                videoIndex: input.videoIndex,
                                vvuid: input.vvuid)
            timePlayed = 0
            isProcessed = false
            return result
        }
    }
}
