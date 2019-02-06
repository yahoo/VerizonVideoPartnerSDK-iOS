//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore


class VRMTimeoutControllerTest: XCTestCase {
    
    let softTimeoutActionComparator = ActionComparator<VRMCore.SoftTimeout> { _,_ in
        return true
    }
    let hardTimeoutActionComparator = ActionComparator<VRMCore.HardTimeout> {
        return $0.items == $1.items
    }
    
    let recorder = Recorder()
    
    var numberOfSoftInitCall: Int!
    var numberOfHardInitCall: Int!
    
    var softTimer: MockTimer!
    var hardTimer: MockTimer!
    
    var softFactory: VRMTimeoutController.TimerFactory!
    var hardFactory: VRMTimeoutController.TimerFactory!
    
    var onFireSoft: VRMTimeoutController.OnFire!
    var onFireHard: VRMTimeoutController.OnFire!
    
    var sut: VRMTimeoutController!
    
    var item1: VRMCore.Item!
    var item2: VRMCore.Item!
    override func setUp() {
        super.setUp()
        item1 = VRMCore.Item(id: .init(),
                             source: .vast(""),
                             metaInfo: .init(engineType: nil,
                                             ruleId: nil,
                                             ruleCompanyId: nil,
                                             vendor: "",
                                             name: nil,
                                             cpm: nil))
        item2 = VRMCore.Item(id: .init(),
                             source: .vast(""),
                             metaInfo: .init(engineType: nil,
                                             ruleId: nil,
                                             ruleCompanyId: nil,
                                             vendor: "",
                                             name: nil,
                                             cpm: nil))
        
        softTimer = MockTimer()
        hardTimer = MockTimer()
        
        softFactory = { onFire in
            self.onFireSoft = onFire
            self.numberOfSoftInitCall += 1
            return self.softTimer
        }
        hardFactory = { onFire in
            self.onFireHard = onFire
            self.numberOfHardInitCall += 1
            return self.hardTimer
        }
        
        numberOfSoftInitCall = 0
        numberOfHardInitCall = 0
    }
    
    override func tearDown() {
        recorder.verify {}
        recorder.clean()
        super.tearDown()
    }
    
    func testFinishCurrentGroup() {
        sut = VRMTimeoutController(dispatch: {_ in},
                                   softTimeoutTimerFactory: softFactory,
                                   hardTimeoutTimerFactory: hardFactory)
        
        sut.process(currentGroup: VRMCore.Group(items: []), fetchingQueue: [])
        
        sut.process(currentGroup: nil, fetchingQueue: [])
        
        XCTAssertTrue(softTimer.didCancelCalled)
        XCTAssertTrue(hardTimer.didCancelCalled)
        XCTAssertEqual(numberOfSoftInitCall, 1)
        XCTAssertEqual(numberOfHardInitCall, 1)
    }
    
    func testCurrentGroupSecondTime() {
        sut = VRMTimeoutController(dispatch: {_ in},
                                   softTimeoutTimerFactory: softFactory,
                                   hardTimeoutTimerFactory: hardFactory)

        
        let currentGruop = VRMCore.Group(items: [item1, item2])
        
        sut.process(currentGroup: currentGruop, fetchingQueue: [])
        sut.process(currentGroup: currentGruop, fetchingQueue: [])
        
        XCTAssertFalse(softTimer.didCancelCalled)
        XCTAssertFalse(hardTimer.didCancelCalled)
        XCTAssertEqual(numberOfSoftInitCall, 1)
        XCTAssertEqual(numberOfHardInitCall, 1)
    }
    
    func testSoftTimeoutReached() {
        let group = VRMCore.Group(items: [])
        let hook = recorder.hook("testSoftTimeoutReached", cmp: softTimeoutActionComparator.compare)
        sut = VRMTimeoutController(dispatch: hook,
                                   softTimeoutTimerFactory: softFactory,
                                   hardTimeoutTimerFactory: hardFactory)
        
        recorder.record {
            sut.process(currentGroup: group, fetchingQueue: [item1, item2])
            onFireSoft()
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.softTimeoutReached())
        }
    }
    
    func testHardTimeoutReached() {
        let group = VRMCore.Group(items: [item1, item2])
        let hook = recorder.hook("testHardTimeoutReached", cmp: hardTimeoutActionComparator.compare)
        sut = VRMTimeoutController(dispatch: hook,
                                   softTimeoutTimerFactory: softFactory,
                                   hardTimeoutTimerFactory: hardFactory)
        
        recorder.record {
            sut.process(currentGroup: group, fetchingQueue: [item1, item2])
            sut.process(currentGroup: group, fetchingQueue: [item1])
            onFireHard()
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.hardTimeoutReached(items: [item1]))
        }
    }
}
