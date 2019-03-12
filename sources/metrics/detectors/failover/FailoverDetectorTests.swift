//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK

class FailoverDetectorsTests: XCTestCase {
    
    var detector: Detectors.Failover!
    
    override func setUp() {
        super.setUp()
        
        detector = Detectors.Failover()
    }
    
    
    func testFailoverDetector() {
        let adSessionID = UUID()
        var result = detector.process(isFailover: false, adSessionID: nil)
        XCTAssertEqual(result, false)
        
        result = detector.process(isFailover: false, adSessionID: adSessionID)
        XCTAssertEqual(result, false)
        
        result = detector.process(isFailover: true, adSessionID: adSessionID)
        XCTAssertEqual(result, true)
        
        result = detector.process(isFailover: true, adSessionID: adSessionID)
        XCTAssertEqual(result, false)
        
        result = detector.process(isFailover: true, adSessionID: UUID())
        XCTAssertEqual(result, true)
    }
}
