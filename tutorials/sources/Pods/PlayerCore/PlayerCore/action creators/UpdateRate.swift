//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public func updateContentPlaybackRate(isPlaying: Bool) -> Action {
    return UpdateContentStreamRate(time: Date(), rate: isPlaying)
}

public func updateAdPlaybackRate(isPlaying: Bool) -> Action {
    return UpdateAdStreamRate(time: Date(), rate: isPlaying)
}

public func contentDidPlay() -> Action { return ContentDidPlay() }
public func contentDidPause(seekInProgress: Bool) -> Action {
    guard seekInProgress == false else { return Nop() }
    return ContentDidPause()
}
public func adDidPlay() -> Action { return AdDidPlay() }
public func adDidPause() -> Action { return AdDidPause() }
