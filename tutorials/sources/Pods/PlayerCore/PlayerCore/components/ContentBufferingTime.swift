//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct ContentBufferingTime {
    static let initial = ContentBufferingTime(status: .empty)
    
    public let status: BufferingStatus
}

func reduce(state: ContentBufferingTime, action: Action) -> ContentBufferingTime {
    switch action {
    case is ContentPlaybackBufferingActive:
        return ContentBufferingTime(status: .inProgress(startAt: Date()))
    case is ContentPlaybackBufferingInactive:
        guard case let .inProgress(startAt) = state.status else { return state }
        return ContentBufferingTime(status: .finished(startAt: startAt, finishAt: Date()))
    case is VRMCore.AdRequest,
         is ContentPlaybackFailed:
        return ContentBufferingTime(status: .empty)
    default:
        return state
    }
}
