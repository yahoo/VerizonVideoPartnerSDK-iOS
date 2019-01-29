//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class StartVRMGroupProcessingControllerTest: XCTestCase {

    let recorder = Recorder()
    let firstGroup = VRMCore.Group(items: [])
    let secondGroup = VRMCore.Group(items: [])
    let id = UUID()
    
    var request: VRMRequestStatus.Request!
    var sut: StartVRMGroupProcessingController!
    
    override func setUp() {
        super.setUp()
        let actionComparator = ActionComparator<VRMCore.StartGroupProcessing> {
            $0.group == $1.group
        }
        let dispatch = recorder.hook("dispatch", cmp: actionComparator.compare)
        sut = StartVRMGroupProcessingController(dispatch: dispatch)
        request = VRMRequestStatus.Request(url: URL(string:"http://test.com")!, id: id)
    }
    
    override func tearDown() {
        recorder.verify {}
        recorder.clean()
        super.tearDown()
    }
    
    func testDispatchFirstGroup() {
        recorder.record {
            sut.process(with: nil,
                        groupsQueue: [firstGroup, secondGroup],
                        isMaxAdSearchReached: false,
                        vrmRequest: request,
                        hasReceivedVRMResponse: true)
        }
    
        recorder.verify {
            sut.dispatch(VRMCore.startGroupProcessing(group: firstGroup))
        }
    }
    
    func testStartLastGroup() {
        recorder.record {
            sut.process(with: nil,
                        groupsQueue: [secondGroup],
                        isMaxAdSearchReached: false,
                        vrmRequest: request,
                        hasReceivedVRMResponse: true)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.startGroupProcessing(group: secondGroup))
        }
    }
    
    func testNonEmptyCurrentGroup() {
        recorder.record {
            sut.process(with: firstGroup,
                        groupsQueue: [secondGroup],
                        isMaxAdSearchReached: false,
                        vrmRequest: request,
                        hasReceivedVRMResponse: true)
        }
        
        recorder.verify {}
    }

    
    func testMaxAdSearchTimeout() {
        recorder.record {
            sut.process(with: nil,
                        groupsQueue: [secondGroup],
                        isMaxAdSearchReached: true,
                        vrmRequest: request,
                        hasReceivedVRMResponse: true)
        }
        
        recorder.verify {}
    }
    
    func testNoMoreGroupForProcessing() {
        let actionComparator = ActionComparator<VRMCore.NoGroupsToProcess> {
            $0.id == $1.id
        }
        let dispatch = recorder.hook("testNoMoreGroupForProcessing", cmp: actionComparator.compare)
        sut = StartVRMGroupProcessingController(dispatch: dispatch)
        
        recorder.record {
            sut.process(with: nil,
                        groupsQueue: [],
                        isMaxAdSearchReached: false,
                        vrmRequest: request,
                        hasReceivedVRMResponse: false)
            
            sut.process(with: nil,
                        groupsQueue: [],
                        isMaxAdSearchReached: false,
                        vrmRequest: request,
                        hasReceivedVRMResponse: true)
            
            sut.process(with: nil,
                        groupsQueue: [],
                        isMaxAdSearchReached: false,
                        vrmRequest: request,
                        hasReceivedVRMResponse: true)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.noGroupsToProcess(id: id))
        }
    }
}
