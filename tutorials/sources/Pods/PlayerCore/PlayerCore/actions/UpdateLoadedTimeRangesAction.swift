//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreMedia

struct UpdateContentLoadedTimeRanges: Action {
    let newValue: [CMTimeRange]
}

struct UpdateAdLoadedTimeRanges: Action {
    let newValue: [CMTimeRange]
}
