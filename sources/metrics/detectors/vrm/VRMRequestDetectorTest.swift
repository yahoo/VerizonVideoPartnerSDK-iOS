//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class VRMRequestDetectorTest: XCTestCase {

    func testDetectSameRequest() {
        let uuid = UUID()
        let sut = Detectors.VRMRequestDetector()
        
        var result = sut.process(with: uuid, transactionId: "id")
        XCTAssertEqual(result?.transactionId, "id")
        
        result = sut.process(with: uuid, transactionId: "id")
        XCTAssertNil(result)
    }

    func testDetectDiffRequests() {
        let sut = Detectors.VRMRequestDetector()
        
        var result = sut.process(with: UUID(), transactionId: "id1")
        XCTAssertEqual(result?.transactionId, "id1")
        
        result = sut.process(with: UUID(), transactionId: "id2")
        XCTAssertEqual(result?.transactionId, "id2")
    }
}
