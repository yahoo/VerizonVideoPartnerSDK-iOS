//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public func contentPlaybackIsReady() -> Action {
    return ContentPlaybackReady()
}

public func contentPlaybackIsFailed(error: NSError) -> Action {
    return ContentPlaybackFailed(error: error)
}

public func adPlaybackIsReady() -> Action {
    return AdPlaybackReady()
}

public func adPlaybackIsFailed(error: NSError) -> Action {
    return AdPlaybackFailed(error: error)
}
