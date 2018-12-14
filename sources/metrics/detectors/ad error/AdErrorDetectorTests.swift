//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import OathVideoPartnerSDK

class AdErrorDetectorTests: XCTestCase {
    var sut: Detectors.AdError!
    
    override func setUp() {
        super.setUp()
        
        sut = Detectors.AdError()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func testProcess() {
        let id = UUID()
        XCTAssertNil(sut.process(id: id, error: nil))
        XCTAssertNil(sut.process(id: id, error: nil))
        struct SomeError: Error { }
        XCTAssertNotNil(sut.process(id: id, error: SomeError()))
        XCTAssertNil(sut.process(id: id, error: SomeError()))
        XCTAssertNil(sut.process(id: UUID(), error: nil))
    }
}
