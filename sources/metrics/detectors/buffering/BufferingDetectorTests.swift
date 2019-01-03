//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK

class BufferingDetectorTests: XCTestCase {
    
    var sut: Detectors.Buffering!
    var result: Detectors.Buffering.Result?
    
    override func setUp() {
        super.setUp()
        
        sut = Detectors.Buffering()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testNoDetections() {
        result = sut.process(isAdBuffering: false)
        XCTAssertEqual(result, .nothing)
    }
    
    func testDetection() {
        result = sut.process(isAdBuffering: true)
        XCTAssertEqual(result, .bufferingStart)
        result = sut.process(isAdBuffering: false)
        XCTAssertEqual(result, .bufferingEnd)
    }
    
    func testMultipleCallsSingleDataDetection() {
        result = sut.process(isAdBuffering: true)
        XCTAssertEqual(result, .bufferingStart)
        result = sut.process(isAdBuffering: true)
        XCTAssertEqual(result, .nothing)
        result = sut.process(isAdBuffering: false)
        XCTAssertEqual(result, .bufferingEnd)
        result = sut.process(isAdBuffering: false)
        XCTAssertEqual(result, .nothing)
    }
}
