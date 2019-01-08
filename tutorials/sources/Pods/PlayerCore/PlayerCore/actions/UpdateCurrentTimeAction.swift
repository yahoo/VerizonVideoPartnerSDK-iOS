//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreMedia

struct UpdateContentCurrentTime: Action {
    let newTime: CMTime
    let currentDate: Date
}

struct UpdateAdCurrentTime: Action {
    let newTime: CMTime
}
