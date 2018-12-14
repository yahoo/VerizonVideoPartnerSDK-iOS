//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import CoreMedia
import PlayerCore
@testable import OathVideoPartnerSDK

extension PlayerCore.AdPixels: Equatable {
    public static func ==(lhs: PlayerCore.AdPixels, rhs: PlayerCore.AdPixels) -> Bool {
        guard lhs.clickTracking == rhs.clickTracking else { return false }
        guard lhs.complete == rhs.complete else { return false }
        guard lhs.creativeView == rhs.creativeView else { return false }
        guard lhs.error == rhs.error else { return false }
        guard lhs.firstQuartile == rhs.firstQuartile else { return false }
        guard lhs.impression == rhs.impression else { return false }
        guard lhs.midpoint == rhs.midpoint else { return false }
        guard lhs.pause == rhs.pause else { return false }
        guard lhs.resume == rhs.resume else { return false }
        guard lhs.start == rhs.start else { return false }
        guard lhs.thirdQuartile == rhs.thirdQuartile else { return false }
        
        return true
    }
}

extension PlayerCore.Ad.VASTModel: Equatable {
    public static func ==(lhs: PlayerCore.Ad.VASTModel, rhs: PlayerCore.Ad.VASTModel) -> Bool {
        guard lhs.mediaFiles.count == rhs.mediaFiles.count else { return false }
        for index in 0..<lhs.mediaFiles.count {
            let lmf = lhs.mediaFiles[index]
            let rmf = rhs.mediaFiles[index]
            guard lhs.id == rhs.id else { return false }
            guard lhs.clickthrough == rhs.clickthrough else { return false }
            guard lmf.maintainAspectRatio == rmf.maintainAspectRatio else { return false }
            guard lmf.url == rmf.url else { return false }
            guard lhs.pixels == rhs.pixels else { return false }
            guard lmf.scalable == rmf.scalable else { return false }
        }
        return true
    }
}

extension VideoSelector: Equatable {
    public static func ==(lhs: VideoSelector, rhs: VideoSelector) -> Bool {
        return lhs.index == rhs.index
    }
}
