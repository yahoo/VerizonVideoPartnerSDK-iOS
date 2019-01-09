//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import CoreMedia

public func seekToTime(time: CMTime, in duration: CMTime?) -> Action {
    guard let duration = duration else { return Nop() }
    guard CMTimeCompare(duration, time) != -1 else { return SeekToTime(newTime: duration) }
    return SeekToTime(newTime: time)
}

public func seekToProgress(progress: Progress, duration: CMTime?) -> Action {
    guard let duration = duration else { return Nop() }
    return seekToTime(time: progress.multiply(time: duration), in: duration)
}

public func seekToSeconds(seconds: Double, timescale: CMTimeScale, duration: CMTime?) -> Action {
    return seekToTime(time: CMTime(seconds: seconds,
                                   preferredTimescale: timescale),
                      in: duration)
}

public func startInteractiveSeeking(progress: Progress, duration: CMTime?) -> Action {
    guard let duration = duration else { return Nop() }
    return StartInteractiveSeeking(newTime: progress.multiply(time: duration))
}

public func stopInteractiveSeeking(progress: Progress, duration: CMTime?) -> Action {
    guard let duration = duration else { return Nop() }
    return StopInteractiveSeeking(newTime: progress.multiply(time: duration))
}

public func didStartSeek() -> Action { return DidStartSeeking() }

public func didStopSeek() -> Action { return DidStopSeeking() }
