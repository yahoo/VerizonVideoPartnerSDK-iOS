//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import XCTest
@testable import OathVideoPartnerSDK

class AdMaxShowTimeDetectorTest: XCTestCase {
    
    var sut: Detectors.AdMaxShowTimeDetector!
    
    override func setUp() {
        super.setUp()
        sut = Detectors.AdMaxShowTimeDetector()
    }
    
    func testMaxShowTimeInRow() {
        let uuid = UUID()
        XCTAssertTrue(sut.process(adKill: .maxShowTime, sessionId: uuid))
        XCTAssertFalse(sut.process(adKill: .maxShowTime, sessionId: uuid))
        XCTAssertFalse(sut.process(adKill: .none, sessionId: uuid))
    }
    
    func testMaxShowTimeInTwoSession() {
        XCTAssertTrue(sut.process(adKill: .maxShowTime, sessionId: UUID()))
        XCTAssertTrue(sut.process(adKill: .maxShowTime, sessionId: UUID()))
    }
}
