//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public struct PlaybackSession {
    public let id: UUID
    public fileprivate(set) var intentTime: Date?
    public fileprivate(set) var startTime: Date?
    public fileprivate(set) var isCompleted: Bool
}

func reduce(state: PlaybackSession, action: Action) -> PlaybackSession {
    var state = state
    switch action {
    case let action as SelectVideoAtIdx:
        return PlaybackSession(id: action.id, intentTime: nil, startTime: nil, isCompleted: false)
        
    case let action as Play where state.intentTime == nil:
        state.intentTime = action.time
    
    case let action as UpdateContentStreamRate where state.startTime == nil && action.rate == true:
        state.startTime = action.time
        
    case is UpdateContentCurrentTime:
        state.isCompleted = false
        
    case is CompletePlaybackSession:
        state.isCompleted = true
        
    default: break
    }
    
    return state
}
