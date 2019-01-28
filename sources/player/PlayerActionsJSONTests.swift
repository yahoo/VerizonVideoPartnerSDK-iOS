//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import CoreMedia
import PlayerCore
@testable import VerizonVideoPartnerSDK

extension VideoSelector: Equatable {
    public static func ==(lhs: VideoSelector, rhs: VideoSelector) -> Bool {
        return lhs.index == rhs.index
    }
}
