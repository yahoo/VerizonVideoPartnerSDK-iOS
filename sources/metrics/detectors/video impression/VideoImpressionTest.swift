//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import XCTest
@testable import VerizonVideoPartnerSDK

class VideoImpressionTest: XCTestCase {
    
    var sut: Detectors.VideoImpression!
    
    override func setUp() {
        super.setUp()
        sut = Detectors.VideoImpression()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func createContext(sessionId: UUID = UUID(),
                       dimensions: CGSize? = .zero,
                       isPlaybackItemAvaliable: Bool = true) -> Detectors.VideoImpression.Context {
        return Detectors.VideoImpression.Context(sessionId: sessionId,
                                                 dimensions: dimensions,
                                                 isPlaybackItemAvaliable: isPlaybackItemAvaliable)
    }
    
    func testSingleCallContentInSameSession() {
        let context = createContext()
        XCTAssertNotNil(sut.process(context: context))
    }
    
    func testMultitimesCallContentInSameSession() {
        let context = createContext()
        XCTAssertNotNil(sut.process(context: context))
        
        XCTAssertNil(sut.process(context: context))
        XCTAssertNil(sut.process(context: context))
    }
    
    func testMultitimesCallContentInDifferentSession() {
        let context1 = createContext()
        XCTAssertNotNil(sut.process(context: context1))
        XCTAssertNil(sut.process(context: context1))
        
        let context2 = createContext()
        XCTAssertNotNil(sut.process(context: context2))
        XCTAssertNil(sut.process(context: context2))
    }
    
    func testContentNotOnScreen() {
        let context = createContext(dimensions: nil)
        XCTAssertNil(sut.process(context: context))
    }
    
    func testContentWithScreenSize() {
        let size = CGSize(width: 600, height: 600)
        let context = createContext(dimensions: size)
        let result = sut.process(context: context)
        
        XCTAssertEqual(size, result?.dimensions)
    }
    
    func testRestrictedVideo() {
        let context = createContext(isPlaybackItemAvaliable: false)
        let result = sut.process(context: context)
        
        XCTAssertNil(result)
    }
}
