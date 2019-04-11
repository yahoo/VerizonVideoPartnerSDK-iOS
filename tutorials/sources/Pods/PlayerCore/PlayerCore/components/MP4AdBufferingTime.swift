//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct MP4AdBufferingTime {
    static let initial = MP4AdBufferingTime(status: .empty)
    
    public let status: BufferingStatus
}

func reduce(state: MP4AdBufferingTime, action: Action) -> MP4AdBufferingTime {
    switch action {
    case is AdPlaybackBufferingActive:
        return MP4AdBufferingTime(status: .inProgress(startAt: Date()))
    case is AdPlaybackBufferingInactive:
            guard case let .inProgress(startAt) = state.status else { return state }
        return MP4AdBufferingTime(status: .finished(startAt: startAt, finishAt: Date()))
        case is AdPlaybackFailed,
             is VRMCore.AdRequest,
             is MP4AdStartTimeout:
        return MP4AdBufferingTime(status: .empty)
    default:
        return state
    }
}
