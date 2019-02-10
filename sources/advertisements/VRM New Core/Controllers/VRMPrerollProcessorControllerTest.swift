//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class VRMPrerollProcessorControllerTest: XCTestCase {
    
    let url = URL(string: "test")!
    let recorder = Recorder()
    let requestID = UUID()
    
    var sut: VRMPrerollProcessorController!
    
    override func setUp() {
        super.setUp()
        let actionComparator = ActionComparator<VRMCore.AdRequest> {
            $0.type == $1.type && $0.url == $1.url && $0.id == $1.id
        }
        let dispatch = recorder.hook("dispatch", cmp: actionComparator.compare)
        
        sut = VRMPrerollProcessorController(dispatch: dispatch)
    }
    
    override func tearDown() {
        recorder.verify {}
        recorder.clean()
        super.tearDown()
    }
    
    func testNoDispatch() {
        recorder.record {
            sut.process(with: nil,
                        isPlaybackInitiated: true,
                        sessionID: UUID())
            
            sut.process(with: url,
                        isPlaybackInitiated: false,
                        sessionID: UUID())
        }
        recorder.verify {}
    }
    
    func testDiffSessions() {
        recorder.record {
            sut.process(with: url,
                        isPlaybackInitiated: true,
                        sessionID: UUID(),
                        requestID: requestID)
            
            sut.process(with: url,
                        isPlaybackInitiated: true,
                        sessionID: UUID(),
                        requestID: requestID)
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.VRMCore.AdRequest(url: url, id: requestID, type: .preroll))
            sut.dispatch(PlayerCore.VRMCore.AdRequest(url: url, id: requestID, type: .preroll))
        }
    }
    
    func testSecondDisptach() {
        recorder.record {
            let sessionID = UUID()
            sut.process(with: url,
                        isPlaybackInitiated: true,
                        sessionID: sessionID,
                        requestID: requestID)
            
            sut.process(with: url,
                        isPlaybackInitiated: true,
                        sessionID: sessionID,
                        requestID: requestID)
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.VRMCore.AdRequest(url: url, id: requestID, type: .preroll))
        }
    }
    
    func testCorrectDispatch() {
        recorder.record {
            sut.process(with: url,
                        isPlaybackInitiated: true,
                        sessionID: UUID(),
                        requestID: requestID)
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.VRMCore.AdRequest(url: url, id: requestID, type: .preroll))
        }
    }
}
