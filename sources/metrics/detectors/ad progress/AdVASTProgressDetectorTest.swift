//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore
class AdProgressDetectorTest: XCTestCase {
    var sut: Detectors.AdVASTProgressDetector!
    var progressPixel: PlayerCore.AdVASTProgress.Pixel!
    let testUrl = URL(string: "http://test.com")!
    
    override func setUp() {
        super.setUp()
        
        sut = Detectors.AdVASTProgressDetector()
        progressPixel = PlayerCore.AdVASTProgress.Pixel(url: testUrl,
                                                    offsetInSeconds: 30)
    }
    
    func testProcessNoPixels() {
        XCTAssertEqual(sut.process(currentTime: 30,
                                   progressPixelsArray: []), [])
    }
    
    func testProcessWithSinglePixel() {
        XCTAssertEqual(sut.process(currentTime: 29,
                                   progressPixelsArray: [progressPixel]), [])
        XCTAssertEqual(sut.process(currentTime: 30,
                                   progressPixelsArray: [progressPixel]), [testUrl])
        XCTAssertEqual(sut.process(currentTime: 30,
                                   progressPixelsArray: [progressPixel]), [])
        XCTAssertEqual(sut.process(currentTime: 31,
                                   progressPixelsArray: [progressPixel]), [])
    }

    func testProcessMultiplePixels() {
        let newTestURL = URL(string: "http://test")!
        let newProgressPixel = PlayerCore.AdVASTProgress.Pixel(url: newTestURL,
                                                           offsetInSeconds: 15)
        XCTAssertEqual(sut.process(currentTime: 14,
                                   progressPixelsArray: [progressPixel, newProgressPixel]), [])
        XCTAssertEqual(sut.process(currentTime: 15,
                                   progressPixelsArray: [progressPixel, newProgressPixel]), [newTestURL])
        XCTAssertEqual(sut.process(currentTime: 15,
                                   progressPixelsArray: [progressPixel, newProgressPixel]), [])
        XCTAssertEqual(sut.process(currentTime: 30,
                                   progressPixelsArray: [progressPixel, newProgressPixel]), [testUrl])
        XCTAssertEqual(sut.process(currentTime: 30,
                                   progressPixelsArray: [progressPixel, newProgressPixel]), [])
    }
}
