//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

func userActionInitiated(hasTime: Bool, shouldPlay: Bool, isNotFinished: Bool) -> Player.Properties.PlaybackItem.Video.ActionInitiated {
    guard hasTime else { return .unknown }
    guard isNotFinished else { return .unknown }
    guard shouldPlay else { return .pause }
    return .play
}
