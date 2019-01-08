//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
public enum AirPlay {
    case inactive
    case restricted
    case active
    case disabled
}

func reduce(state: AirPlay, action: Action) -> AirPlay {
    switch action {
    case is UpdateExternalPlaybackPossible:
        return .inactive
    case is UpdateExternalPlaybackImpossible:
        return .disabled
    case is UpdateExternalPlaybackActive:
        return .active
    case is UpdateExternalPlaybackInactive:
        return .disabled
    default: return state
    }
}

