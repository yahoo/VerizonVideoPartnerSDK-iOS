//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import Nimble
@testable import VerizonVideoPartnerSDK

class DecileDetectorTests: XCTestCase {
    var sut: Detectors.Decile!
    let id = UUID()
    let nextId = UUID()
    
    override func setUp() {
        super.setUp()
        sut = Detectors.Decile()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testNoReportingAtZeroProgress() {
        var results = [] as [Detectors.Decile.Result]
        
        results.append(contentsOf: sut.process(decile: nil,
                                               playing: true,
                                               sessionId: id))
        
        expect(results.count) == 0
    }
    
    func testReportFirstDecile() {
        var results = [] as [Detectors.Decile.Result]
        results.append(contentsOf: sut.process(decile: 1,
                                               playing: true,
                                               sessionId: id))
        
        expect(results.count) == 1
        expect(results[0].newDecile) == 1
    }
    
    func testReportFirstDecileSentOnlyOnce() {
        var results = [] as [Detectors.Decile.Result]
        results.append(contentsOf: sut.process(decile: 1, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(decile: 1, playing: true, sessionId: id))
        
        expect(results.count) == 1
        expect(results[0].newDecile) == 1
    }
    
    func testReportNotRepeatedWhenSeekBack() {
        var results = [] as [Detectors.Decile.Result]
        results.append(contentsOf: sut.process(decile: 1, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(decile: 0, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(decile: 1, playing: true, sessionId: id))
        
        expect(results.count) == 1
        expect(results[0].newDecile) == 1
    }
    
    func testReportWithSeveralEventsInARow() {
        var results = [] as [Detectors.Decile.Result]
        results.append(contentsOf: sut.process(decile: 1, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(decile: 2, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(decile: 3, playing: true, sessionId: id))
        
        expect(results.count) == 3
        expect(results[0].newDecile) == 1
        expect(results[1].newDecile) == 2
        expect(results[2].newDecile) == 3
    }
    
    func testReportOverSeveralDeciles() {
        var results = [] as [Detectors.Decile.Result]
        results.append(contentsOf: sut.process(decile: 5, playing: true, sessionId: id))
        
        expect(results.count) == 5
        expect(results[0].newDecile) == 1
        expect(results[1].newDecile) == 2
        expect(results[2].newDecile) == 3
        expect(results[3].newDecile) == 4
        expect(results[4].newDecile) == 5
    }
    
    func testReportNegativeProgress() {
        var results = [] as [Detectors.Decile.Result]
        results.append(contentsOf: sut.process(decile: -1, playing: true, sessionId: id))
        
        expect(results.count) == 0
    }
    
    func testReportMoreThan1Progress() {
        var results = [] as [Detectors.Decile.Result]
        results.append(contentsOf: sut.process(decile: 20, playing: true, sessionId: id))
        
        expect(results.count) == 10
        expect(results[0].newDecile) == 1
        expect(results[1].newDecile) == 2
        expect(results[2].newDecile) == 3
        expect(results[3].newDecile) == 4
        expect(results[4].newDecile) == 5
        expect(results[5].newDecile) == 6
        expect(results[6].newDecile) == 7
        expect(results[7].newDecile) == 8
        expect(results[8].newDecile) == 9
        expect(results[9].newDecile) == 10
    }
    
    func testReportOnNextVideo() {
        var results = [] as [Detectors.Decile.Result]
        results.append(contentsOf: sut.process(decile: 2, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(decile: 1, playing: true, sessionId: UUID()))
        
        expect(results.count) == 3
        expect(results[0].newDecile) == 1
        expect(results[1].newDecile) == 2
        expect(results[2].newDecile) == 1
    }
    
    func testReportOnPreviousVideo() {
        var results = [] as [Detectors.Decile.Result]
        results.append(contentsOf: sut.process(decile: 2, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(decile: 1, playing: true, sessionId: UUID()))
        results.append(contentsOf: sut.process(decile: 2, playing: true, sessionId: id))
        
        expect(results.count) == 5
        expect(results[0].newDecile) == 1
        expect(results[1].newDecile) == 2
        expect(results[2].newDecile) == 1
        expect(results[3].newDecile) == 1
        expect(results[4].newDecile) == 2
    }
    
    func testReportIfPlayInitiated() {
        var results = [] as [Detectors.Decile.Result]
        results.append(contentsOf: sut.process(decile: 1, playing: true, sessionId: id))
        results.append(contentsOf: sut.process(decile: 3, playing: false, sessionId: id))
        
        expect(results.count) == 3
        expect(results[0].newDecile) == 1
        expect(results[1].newDecile) == 2
        expect(results[2].newDecile) == 3
    }
    
    func testNoReportWithoutPlayEvent() {
        var results = [] as [Detectors.Decile.Result]
        results.append(contentsOf: sut.process(decile: 2, playing: false, sessionId: id))
        results.append(contentsOf: sut.process(decile: 1, playing: false, sessionId: UUID()))
        results.append(contentsOf: sut.process(decile: 2, playing: false, sessionId: id))
        
        expect(results.count) == 0
    }
    
    func testFireOnFirstPlay() {
        var results = [] as [Detectors.Decile.Result]
        results.append(contentsOf: sut.process(decile: 2, playing: false, sessionId: id))
        results.append(contentsOf: sut.process(decile: 1, playing: false, sessionId: nextId))
        results.append(contentsOf: sut.process(decile: 2, playing: true, sessionId: nextId))
        
        expect(results.count) == 2
        expect(results[0].newDecile) == 1
        expect(results[1].newDecile) == 2
    }
    
    func testSessionIdTracking() {
        var results = [] as [Detectors.Decile.Result]
        results.append(contentsOf: sut.process(decile: 2, playing: false, sessionId: id))
        results.append(contentsOf: sut.process(decile: 1, playing: false, sessionId: nextId))
        results.append(contentsOf: sut.process(decile: 2, playing: true, sessionId: nextId))
        results.append(contentsOf: sut.process(decile: 1, playing: true, sessionId: UUID()))
        
        expect(results.count) == 3
        expect(results[0].newDecile) == 1
        expect(results[1].newDecile) == 2
        expect(results[2].newDecile) == 1
    }
    
    func testNotTriggeredOnLiveOrUnknown() {
        let results = sut.process(decile: 1, playing: true, sessionId: UUID(), isStatic: false)
        expect(results.count) == 0
    }
}
