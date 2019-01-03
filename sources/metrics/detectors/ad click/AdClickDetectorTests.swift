//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK

class AdClickDetectorTests: XCTestCase {
    var sut: Detectors.AdClick!
    
    override func setUp() {
        super.setUp()
        
        sut = Detectors.AdClick()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func testProcess() {
        XCTAssertTrue(sut.process(clicked: true))
        XCTAssertFalse(sut.process(clicked: true))
        XCTAssertFalse(sut.process(clicked: false))
        XCTAssertFalse(sut.process(clicked: false))
    }
}
