//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import PlayerCore
@testable import VerizonVideoPartnerSDK

class VPAIDEventsTest: XCTestCase {

    func test() {
        let sut = Detectors.VPAIDEventsDetector()
        var result = sut.process(events: [])
        XCTAssertEqual(sut.trackingEvents.count, 0)
        
        result = sut.process(events: [VPAIDEvents.AdNotSupported])
        XCTAssertEqual(sut.trackingEvents.count, 1)
        XCTAssertEqual(result, [VPAIDEvents.AdNotSupported])
        
        result = sut.process(events: [VPAIDEvents.AdNotSupported, VPAIDEvents.AdImpression])
        XCTAssertEqual(sut.trackingEvents.count, 2)
        XCTAssertEqual(result, [VPAIDEvents.AdImpression])
        
        result = sut.process(events: [VPAIDEvents.AdNotSupported, VPAIDEvents.AdImpression])
        XCTAssertEqual(sut.trackingEvents.count, 2)
        XCTAssertEqual(result, [])
    }
}

extension PlayerCore.VPAIDEvents: Equatable {
    public static func == (lhs: VPAIDEvents, rhs: VPAIDEvents) -> Bool {
        switch (lhs, rhs) {
        case (AdNotSupported, AdNotSupported): return true
        case (AdDurationChange, AdDurationChange): return true
        case (.AdCurrentTimeChanged, .AdCurrentTimeChanged): return true
        case (.AdLoaded, .AdLoaded): return true
        case (.AdStarted, .AdStarted): return true
        case (.AdStopped, .AdStopped): return true
        case (.AdSkipped, .AdSkipped): return true
        case (.AdPaused, .AdPaused): return true
        case (.AdResumed, .AdResumed): return true
        case (.AdClickThru, .AdClickThru): return true
        case (.AdError, .AdError): return true
        case (.AdJSEvaluationFailed, .AdJSEvaluationFailed): return true
        case (.AdImpression, .AdImpression): return true
        case (.AdVideoStart, .AdVideoStart): return true
        case (.AdVideoFirstQuartile, .AdVideoFirstQuartile): return true
        case (.AdVideoMidpoint, .AdVideoMidpoint): return true
        case (.AdVideoThirdQuartile, .AdVideoThirdQuartile): return true
        case (.AdVideoComplete, .AdVideoComplete): return true
        case (.AdWindowOpen, .AdWindowOpen): return true
        case (.AdUserAcceptInvitation, .AdUserAcceptInvitation): return true
        case (.AdUserMinimize, .AdUserMinimize): return true
        case (AdUserClose, AdUserClose): return true
        case (AdVolumeChange, AdVolumeChange): return true
        case (AdScriptLoaded, AdScriptLoaded): return true
        case (AdUniqueEventAbuse, AdUniqueEventAbuse): return true
        default: return false
        }
    }
}
