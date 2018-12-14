//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import Nimble

@testable import OathVideoPartnerSDK

class QuartileDetectorTests: XCTestCase {
    var sut: Detectors.Quartile!
    let id = UUID()
    
    override func setUp() {
        super.setUp()
        sut = Detectors.Quartile()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testNoReportingAtZeroProgress() {
        let result = sut.process(quartile: nil, playing: true, sessionId: id)
        
        expect(result.count) == 0
    }
    
    func testReportFirstQuartile() {
        let result = sut.process(quartile: 1, playing: true, sessionId: id)
        
        expect(result.count) == 1
        expect(result[0].newQuartile) == 1
    }
    
    func testReportFirstDecileSentOnlyOnce() {
        var results = [] as [Detectors.Quartile.Result]
        results.append(contentsOf: sut.process(quartile: 1, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(quartile: 1, playing: true, sessionId: id))
        
        expect(results.first?.newQuartile) == 1
    }
    
    func testReportNotRepeatedWhenSeekBack() {
        var results = [] as [Detectors.Quartile.Result]
        results.append(contentsOf: sut.process(quartile: 1, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(quartile: 0, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(quartile: 1, playing: true, sessionId: id))
        
        expect(results.first?.newQuartile) == 1
    }
    
    func testReportWithSeveralEventsInARow() {
        var results = [] as [Detectors.Quartile.Result]
        results.append(contentsOf: sut.process(quartile: 1, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(quartile: 2, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(quartile: 3, playing: true, sessionId: id))
        
        expect(results.count) == 3
        expect(results[0].newQuartile) == 1
        expect(results[1].newQuartile) == 2
        expect(results[2].newQuartile) == 3
    }
    
    func testReportOverSeveralDeciles() {
        var results = [] as [Detectors.Quartile.Result]
        results.append(contentsOf: sut.process(quartile: 3, playing: true, sessionId: id))
        
        expect(results.count) == 3
        expect(results[0].newQuartile) == 1
        expect(results[1].newQuartile) == 2
        expect(results[2].newQuartile) == 3
    }
    
    func testReportNegativeProgress() {
        var results = [] as [Detectors.Quartile.Result]
        results.append(contentsOf: sut.process(quartile: -1, playing: true, sessionId: id))
        expect(results.count) == 0
    }
    
    func testReportMoreThan1Progress() {
        var results = [] as [Detectors.Quartile.Result]
        results.append(contentsOf: sut.process(quartile: 8, playing: true, sessionId: id))
        
        expect(results.count) == 4
        expect(results[0].newQuartile) == 1
        expect(results[1].newQuartile) == 2
        expect(results[2].newQuartile) == 3
        expect(results[3].newQuartile) == 4
    }
    
    func testReportOnNextVideo() {
        var results = [] as [Detectors.Quartile.Result]
        
        results.append(contentsOf: sut.process(quartile: 2, playing: true, sessionId: UUID()))
        results.append(contentsOf: sut.process(quartile: 1, playing: true, sessionId: UUID()))
        
        expect(results.count) == 3
        expect(results[0].newQuartile) == 1
        expect(results[1].newQuartile) == 2
        expect(results[2].newQuartile) == 1
    }
    
    func testReportOnPreviousVideo() {
        var results = [] as [Detectors.Quartile.Result]
        
        results.append(contentsOf: sut.process(quartile: 2, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(quartile: 1, playing: true, sessionId: UUID()))
        results.append(contentsOf: sut.process(quartile: 2, playing: true, sessionId: id))
        
        expect(results.count) == 5
        expect(results[0].newQuartile) == 1
        expect(results[1].newQuartile) == 2
        expect(results[2].newQuartile) == 1
        expect(results[3].newQuartile) == 1
        expect(results[4].newQuartile) == 2
    }
    
    func testReportIfPlayInitiated() {
        var results = [] as [Detectors.Quartile.Result]
        results.append(contentsOf: sut.process(quartile: 1, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(quartile: 3, playing: false, sessionId: id))
        
        expect(results.count) == 3
        expect(results[0].newQuartile) == 1
        expect(results[1].newQuartile) == 2
        expect(results[2].newQuartile) == 3
    }
    
    func testNoReportWithoutPlayEvent() {
        var results = [] as [Detectors.Quartile.Result]
        results.append(contentsOf: sut.process(quartile: 2, playing: false, sessionId: id))
        results.append(contentsOf: sut.process(quartile: 1, playing: false, sessionId: id))
        results.append(contentsOf: sut.process(quartile: 2, playing: false, sessionId: id))
        
        expect(results.count) == 0
    }
    
    func testFireOnFirstPlay() {
        var results = [] as [Detectors.Quartile.Result]
        results.append(contentsOf: sut.process(quartile: 2, playing: false, sessionId: id))
        results.append(contentsOf: sut.process(quartile: 1, playing: false, sessionId: id))
        results.append(contentsOf: sut.process(quartile: 2, playing: true, sessionId: id))
        
        expect(results.count) == 2
        expect(results[0].newQuartile) == 1
        expect(results[1].newQuartile) == 2
    }
    
    func testSessionIdTracking() {
        var results = [] as [Detectors.Quartile.Result]
        results.append(contentsOf: sut.process(quartile: 2, playing: false, sessionId: id))
        results.append(contentsOf: sut.process(quartile: 1, playing: false, sessionId: id))
        results.append(contentsOf: sut.process(quartile: 2, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(quartile: 1, playing: true, sessionId: UUID()))
        
        expect(results.count) == 3
        expect(results[0].newQuartile) == 1
        expect(results[1].newQuartile) == 2
        expect(results[2].newQuartile) == 1
    }
    
    func testReturningToAlreadyRecordedVideo() {
        var results = [] as [Detectors.Quartile.Result]
        
        results.append(contentsOf: sut.process(quartile: 4, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(quartile: nil, playing: false, sessionId: UUID()))
        results.append(contentsOf: sut.process(quartile: 4, playing: true, sessionId: id))
        
        expect(results.count) == 8
        expect(results[0].newQuartile) == 1
        expect(results[1].newQuartile) == 2
        expect(results[2].newQuartile) == 3
        expect(results[3].newQuartile) == 4
        expect(results[4].newQuartile) == 1
        expect(results[5].newQuartile) == 2
        expect(results[6].newQuartile) == 3
        expect(results[7].newQuartile) == 4
    }
    
    func testNotTriggeredOnLiveOrUnknownVideo() {
        let results = sut.process(quartile: 3,
                                  playing: true,
                                  sessionId: UUID(),
                                  isStatic: false)
        expect(results.count) == 0
    }
}
