//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public enum MP4AdBufferingTime {
    static let initial = MP4AdBufferingTime.empty
    
    case inProgress(startAt: Date)
    case finished(startAt: Date, finishAt: Date)
    case empty
}

func reduce(state: MP4AdBufferingTime, action: Action) -> MP4AdBufferingTime {
    switch action {
    case is AdPlaybackBufferingActive:
        return .inProgress(startAt: Date())
    case is AdPlaybackBufferingInactive:
            guard case let .inProgress(startAt) = state else { return state }
        return .finished(startAt: startAt, finishAt: Date())
        case is AdPlaybackFailed,
             is VRMCore.AdRequest,
             is AdRequest,
             is AdStartTimeout:
        return .empty
    default:
        return state
    }
}
