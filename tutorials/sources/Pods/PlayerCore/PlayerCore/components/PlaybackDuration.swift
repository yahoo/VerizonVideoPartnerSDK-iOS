//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public struct PlaybackDuration {
    public let startTime: Date?
    public let duration: TimeInterval
}

func reduce(state: PlaybackDuration, action: Action) -> PlaybackDuration {
    switch action {
    case let action as UpdateContentStreamRate:
        guard state.startTime == nil && action.rate == true else { return state }
        return PlaybackDuration(startTime: action.time, duration: state.duration)
        
    case is SelectVideoAtIdx:
        return PlaybackDuration(startTime: nil, duration: 0)
        
    case let action as UpdateContentCurrentTime:
        guard let startTime = state.startTime else { return state }
        let deltaDuration = action.currentDate.timeIntervalSince(startTime)
        return PlaybackDuration(startTime: action.currentDate, duration: state.duration + deltaDuration)
        
    default:
        return state
    }
}
