//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
public func contentEndPlayback(currentIdx: Int, count: Int, prerolls: [Int], midrolls: [[Midroll]]) -> Action {
    let hasNextVideo = currentIdx + 1 < count
    return hasNextVideo ? next(currentIdx: currentIdx, prerolls: prerolls, midrolls: midrolls) : completePlaybackSession()
}

public func adEndPlayback() -> Action {
    return ShowContent()
}
