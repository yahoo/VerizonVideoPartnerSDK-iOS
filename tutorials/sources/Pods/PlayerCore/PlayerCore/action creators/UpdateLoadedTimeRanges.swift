//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreMedia

public func updateContentLoadedTimeRanges(ranges: [CMTimeRange]) -> Action {
    return UpdateContentLoadedTimeRanges(newValue: ranges)
}

public func updateAdLoadedTimeRanges(ranges: [CMTimeRange]) -> Action {
    return UpdateAdLoadedTimeRanges(newValue: ranges)
}

public func updateContentBufferedTime(time: CMTime) -> Action {
    let range = CMTimeRange(start: CMTime.zero, end: time)
    return updateContentLoadedTimeRanges(ranges: [range])
}

public func updateAdBufferedTime(time: CMTime) -> Action {
    let range = CMTimeRange(start: CMTime.zero, end: time)
    return updateAdLoadedTimeRanges(ranges: [range])
}
