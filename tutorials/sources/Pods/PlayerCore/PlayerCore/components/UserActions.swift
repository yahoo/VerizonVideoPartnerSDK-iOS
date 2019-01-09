//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

public enum UserActions {
    case play, pause, nothing
}

func reduce(state: UserActions, action: Action) -> UserActions {
    switch action {
    case is Play:
        return .play
    case is Pause:
        return .pause
    case is UpdateAdStreamRate:
        return .nothing
    default: return state
    }
}
