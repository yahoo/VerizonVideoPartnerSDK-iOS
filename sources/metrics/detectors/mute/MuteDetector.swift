//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    final class Mute {
        enum Result { case nothing, mute, unmute }
        
        var lastResult = Result.unmute
        
        func process(isMuted: Bool, isNotFinished: Bool, isOMActive: Bool) -> Result {
            guard isOMActive else { return .nothing }
            return process(isMuted: isMuted, isNotFinished: isNotFinished)
        }
        func process(isMuted: Bool, isNotFinished: Bool) -> Result {
            guard isNotFinished else {
                lastResult = .unmute
                return .nothing
            }
            let result: Result = {
                return isMuted ? .mute : .unmute
            }()
            
            guard result != lastResult else { return .nothing }
            lastResult = result
            
            return result
        }
    }
}
