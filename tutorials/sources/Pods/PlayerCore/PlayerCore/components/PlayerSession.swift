//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public struct PlayerSession {
    public let id: UUID
    public let creationTime: Date
    public let isCompleted: Bool
    public let isStarted: Bool
}

func reduce(state: PlayerSession, action: Action) -> PlayerSession {
    switch action {
        
    case is SelectVideoAtIdx:
        return PlayerSession(id: state.id,
                             creationTime: state.creationTime,
                             isCompleted: state.isCompleted,
                             isStarted: true)
        
    case is CompletePlayerSession:
        return PlayerSession(id: state.id,
                             creationTime: state.creationTime,
                             isCompleted: true,
                             isStarted: state.isStarted)
        
    case is Play,is ContentDidPlay:
        return PlayerSession(id: state.id,
                             creationTime: state.creationTime,
                             isCompleted: state.isCompleted,
                             isStarted: true)
        
    default: return state
    }
}
