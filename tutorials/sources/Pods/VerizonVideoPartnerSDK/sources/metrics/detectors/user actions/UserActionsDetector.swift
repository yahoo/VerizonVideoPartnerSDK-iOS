//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    final class UserActions {
        enum Result { case nothing, didPause, didPlay }
        enum PossibleActions { case nothing, play, pause }
        
        private var result = Result.nothing
        
        func render(hasTime: Bool, action: PossibleActions) -> Result {
            guard hasTime else { result = .nothing; return result }
            switch action {
            case .play:
                guard result == .didPause else { return .nothing }
                result = .didPlay
                return result
            case .pause:
                guard result != .didPause else { return .nothing }
                result = .didPause
                return result
            default: return .nothing
            }
        }
    }
}
