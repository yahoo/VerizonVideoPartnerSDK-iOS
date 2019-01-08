//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    final class Buffering {
        
        var lastResult = Result.nothing
        enum Result {
            case nothing
            case bufferingStart
            case bufferingEnd
        }
        
        func process(isAdBuffering: Bool) -> Result {
            switch(lastResult, isAdBuffering) {
            case (.nothing, true),
                 (.bufferingEnd, true):
                lastResult = .bufferingStart
                return .bufferingStart
            case (.bufferingStart, false):
                lastResult = .bufferingEnd
                return .bufferingEnd
            default:
                return .nothing
            }
        }
    }
}

