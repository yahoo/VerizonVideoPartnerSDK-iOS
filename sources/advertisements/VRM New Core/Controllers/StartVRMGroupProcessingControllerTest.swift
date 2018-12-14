//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import OathVideoPartnerSDK
@testable import PlayerCore

class StartVRMGroupProcessingControllerTest: XCTestCase {

    let recorder = Recorder()
    let firstGroup = VRMCore.Group(items: [])
    let secondGroup = VRMCore.Group(items: [])
    
    var sut: StartVRMGroupProcessingController!
    
    override func setUp() {
        super.setUp()
        let dispatch = recorder.hook("testDispatchFirstGroup") { target, recorded in
            guard let target = target as? PlayerCore.VRMCore.StartGroupProcessing,
                let recorded = recorded as? PlayerCore.VRMCore.StartGroupProcessing else {
                    return false
            }
            return target.group == recorded.group
            
            } as (PlayerCore.Action) -> ()
        
        sut = StartVRMGroupProcessingController(dispatch: dispatch)
    }
    
    override func tearDown() {
        recorder.verify {}
        recorder.clean()
        super.tearDown()
    }
    
    func testDispatchFirstGroup() {
        recorder.record {
            sut.process(with: nil,
                        groupsQueue: [firstGroup, secondGroup])
        }
    
        recorder.verify {
            sut.dispatch(VRMCore.startGroupProcessing(group: firstGroup))
        }
    }
    
    func testStartLastGroup() {
        recorder.record {
            sut.process(with: nil,
                        groupsQueue: [secondGroup])
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.startGroupProcessing(group: secondGroup))
        }
    }
    
    func testNonEmptyCurrentGroup() {
        recorder.record {
            sut.process(with: firstGroup,
                        groupsQueue: [secondGroup])
        }
        
        recorder.verify {}
    }
    
    func testEmptyCurrentGroupAndQueue() {
        recorder.record {
            sut.process(with: nil,
                        groupsQueue: [])
        }
        
        recorder.verify {}
    }
}
