//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

struct StartTimer: Action {
    let date: Date
}

struct PauseTimer: Action {
    let date: Date
}

struct StopTimer: Action {
    let maxAdDuration: Int
    init(maxAdDuration: Int) {
        self.maxAdDuration = maxAdDuration
    }
}
