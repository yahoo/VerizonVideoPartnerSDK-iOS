//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

struct UpdateContentStreamRate: Action {
    let time: Date
    let rate: Bool
}

struct UpdateAdStreamRate: Action {
    let time: Date
    let rate: Bool
}

struct ContentDidPlay: Action { }
struct ContentDidPause: Action { }
struct AdDidPlay: Action { }
struct AdDidPause: Action { }
