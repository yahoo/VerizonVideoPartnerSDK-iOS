//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation.NSError

struct ContentPlaybackFailed: Action {
    let error: NSError
}

struct AdPlaybackFailed: Action {
    let error: NSError
}
