//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public struct Mute {
    public let player: Bool
    public let vpaid: Bool
}

func reduce(state: Mute, action: Action) -> Mute {
    switch action {
    case is PlayerMute:
        return Mute(player: true, vpaid: true)
    case is PlayerUnmute:
        return Mute(player: false, vpaid: false)
    case let action as AdVolumeChange:
        let isVPAIDMuted = action.volume == 0
        return Mute(player: state.player, vpaid: isVPAIDMuted)
    case is ShowAd:
        return Mute(player: state.player, vpaid: state.player)
    default: return state        
    }
}
