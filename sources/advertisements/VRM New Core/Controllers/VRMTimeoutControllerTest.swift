//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore


class VRMTimeoutControllerTest: XCTestCase {
    var numberOfSoftInitCall: Int!
    var numberOfHardInitCall: Int!
    
    var softTimer: MockTimer!
    var hardTimer: MockTimer!
    
    var sut: VRMTimeoutController!
    
    override func setUp() {
        super.setUp()
        softTimer = MockTimer()
        hardTimer = MockTimer()
        let softFactory: () -> Cancellable = {
            self.numberOfSoftInitCall += 1
            return self.softTimer
        }
        let hardFactory: () -> Cancellable = {
            self.numberOfHardInitCall += 1
            return self.hardTimer
        }
        
        sut = VRMTimeoutController(softTimeoutTimerFactory: softFactory,
                                   hardTimeoutTimerFactory: hardFactory)
        
        numberOfSoftInitCall = 0
        numberOfHardInitCall = 0
    }
    
    func testFinishCurrentGroup() {
        sut.process(currentGroup: VRMCore.Group(items: []))
        
        sut.process(currentGroup: nil)
        
        XCTAssertTrue(softTimer.didCancelCalled)
        XCTAssertTrue(hardTimer.didCancelCalled)
        XCTAssertEqual(numberOfSoftInitCall, 1)
        XCTAssertEqual(numberOfHardInitCall, 1)
    }
    
    func testCurrentGroupSecondTime() {
        let currentGruop = VRMCore.Group(items: [])
        
        sut.process(currentGroup: currentGruop)
        sut.process(currentGroup: currentGruop)
        
        XCTAssertFalse(softTimer.didCancelCalled)
        XCTAssertFalse(hardTimer.didCancelCalled)
        XCTAssertEqual(numberOfSoftInitCall, 1)
        XCTAssertEqual(numberOfHardInitCall, 1)
    }
}
