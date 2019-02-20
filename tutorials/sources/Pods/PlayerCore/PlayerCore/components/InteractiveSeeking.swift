//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
public struct InteractiveSeeking {
    public let isSeekingInProgress: Bool
}

func reduce(state: InteractiveSeeking, action: Action) -> InteractiveSeeking {
    switch action {
    case is StartInteractiveSeeking: return InteractiveSeeking(isSeekingInProgress: true)
    case is StopInteractiveSeeking: return InteractiveSeeking(isSeekingInProgress: false)
    case is SelectVideoAtIdx: return InteractiveSeeking(isSeekingInProgress: false)
    case is ShowMP4Ad, is ShowVPAIDAd, is ShowAd: return InteractiveSeeking(isSeekingInProgress: false)
    case is ShowContent, is DropAd: return InteractiveSeeking(isSeekingInProgress: false)
    default: return state
    }
}
