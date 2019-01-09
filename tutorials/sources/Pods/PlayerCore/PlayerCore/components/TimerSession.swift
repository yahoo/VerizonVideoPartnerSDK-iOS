//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct TimerSession {
    public enum State { case running, paused, stopped }
    
    public let state: State
    public let startAdSession: Date?
    public let allowedDuration: TimeInterval
}

public func reduce(state: TimerSession, action: Action) -> TimerSession {
    switch action {
    case let start as StartTimer where state.state != .running:
        return TimerSession(state: .running,
                            startAdSession: start.date,
                            allowedDuration: state.allowedDuration)

    case let pause as PauseTimer where state.state == .running:
        let allowedDuration = state.allowedDuration - pause.date.timeIntervalSince(state.startAdSession!)
        return TimerSession(state: .paused,
                            startAdSession: state.startAdSession,
                            allowedDuration: allowedDuration)

    case let stop as StopTimer:
        return TimerSession(state: .stopped,
                            startAdSession: nil,
                            allowedDuration: Double(stop.maxAdDuration))
        
    default: return state
    }
}
