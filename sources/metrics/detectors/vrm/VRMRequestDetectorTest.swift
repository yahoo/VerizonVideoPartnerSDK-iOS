//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class VRMRequestDetectorTest: XCTestCase {
    
    func testDetectSameRequest() {
        let uuid = UUID()
        let sut = Detectors.VRMRequestDetector()
        
        var result = sut.process(with: uuid, vrmResponseStatus: .response(transactionID: "id"))
        XCTAssertEqual(result?.transactionId, "id")
        
        result = sut.process(with: uuid, vrmResponseStatus: .response(transactionID: "id"))
        XCTAssertNil(result)
    }

    func testDetectDiffRequests() {
        let sut = Detectors.VRMRequestDetector()
        
        var result = sut.process(with: UUID(), vrmResponseStatus: .response(transactionID: "id"))
        XCTAssertEqual(result?.transactionId, "id")
        
        result = sut.process(with: UUID(), vrmResponseStatus: .response(transactionID: "id"))
        XCTAssertEqual(result?.transactionId, "id")
    }
    
    func testNoDetectionIfResponseNil() {
        let sut = Detectors.VRMRequestDetector()
        
        let result = sut.process(with: UUID(), vrmResponseStatus: .noResponse)
        
        XCTAssertNil(result)
    }
}
