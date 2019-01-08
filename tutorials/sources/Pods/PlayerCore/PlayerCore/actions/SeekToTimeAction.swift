//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreMedia

struct SeekToTime: Action {
    let newTime: CMTime
}

struct StartInteractiveSeeking: Action {
    let newTime: CMTime
}

struct StopInteractiveSeeking: Action {
    let newTime: CMTime
}

struct DidStartSeeking: Action {}

struct DidStopSeeking: Action {}
