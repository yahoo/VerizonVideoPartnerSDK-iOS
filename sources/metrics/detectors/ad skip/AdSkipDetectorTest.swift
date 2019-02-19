//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import XCTest
@testable import VerizonVideoPartnerSDK

class AdSkipDetectorTest: XCTestCase {
    var sut: Detectors.AdSkipDetector!
    var id: UUID!
    
    override func setUp() {
        super.setUp()
        
        sut = Detectors.AdSkipDetector()
        id = UUID()
    }
    
    func testProcess() {
        XCTAssertFalse(sut.process(isSkipped: false, id: id))
        XCTAssertTrue(sut.process(isSkipped: true, id: id))
        XCTAssertFalse(sut.process(isSkipped: true, id: id))
        XCTAssertTrue(sut.process(isSkipped: true, id: UUID()))
    }
}
