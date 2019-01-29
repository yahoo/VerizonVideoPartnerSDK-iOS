//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class StartAdProcessingControllerTest: XCTestCase {
    
    let url = URL(string: "test")!
    let recorder = Recorder()
    let requestID = UUID()
    let midrolls: [PlayerCore.Ad.Midroll] = [.init(cuePoint: 10, url: URL(string: "http://some_url_1")!, id: UUID()),
                                             .init(cuePoint: 15, url: URL(string: "http://some_url_2")!, id: UUID()),
                                             .init(cuePoint: 20, url: URL(string: "http://some_url_3")!, id: UUID())]
    
    var sut: StartAdProcessingController!
    
    override func setUp() {
        super.setUp()
        let actionComparator = ActionComparator<VRMCore.AdRequest> {
            $0.type == $1.type && $0.url == $1.url && $0.id == $1.id
        }
        let dispatch = recorder.hook("dispatch", cmp: actionComparator.compare)
        
        sut = StartAdProcessingController(prefetchOffset: 5, dispatch: dispatch)
    }
    
    override func tearDown() {
        recorder.verify {}
        recorder.clean()
        super.tearDown()
    }
    
    func testNoDispatch() {
        recorder.record {
            sut.processPreroll(with: nil,
                               isPlaybackInitiated: true,
                               sessionID: UUID())
            
            sut.processPreroll(with: url,
                               isPlaybackInitiated: false,
                               sessionID: UUID())
        }
        recorder.verify {}
    }
    
    func testDiffSessions() {
        recorder.record {
            sut.processPreroll(with: url,
                               isPlaybackInitiated: true,
                               sessionID: UUID(),
                               requestID: requestID)
            
            sut.processPreroll(with: url,
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
            sut.processPreroll(with: url,
                               isPlaybackInitiated: true,
                               sessionID: sessionID,
                               requestID: requestID)
            
            sut.processPreroll(with: url,
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
            sut.processPreroll(with: url,
                               isPlaybackInitiated: true,
                               sessionID: UUID(),
                               requestID: requestID)
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.VRMCore.AdRequest(url: url, id: requestID, type: .preroll))
        }
    }
    
    func testTimeToPlayMidroll() {
        let midroll = midrolls[0]
        recorder.record {
            sut.processMidroll(midrolls: midrolls,
                               currentTime: 10.0,
                               hasActiveAds: false,
                               isPlayMidrollAllowed: true)
            
            sut.processMidroll(midrolls: midrolls,
                               currentTime: 14.0,
                               hasActiveAds: false,
                               isPlayMidrollAllowed: true)
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.VRMCore.AdRequest(url: midroll.url,
                                                      id: midroll.id,
                                                      type: .midroll))
        }
    }
    
    func testSeekOverFirstMidroll() {
        let midroll = midrolls[0]
        recorder.record {
            sut.processMidroll(midrolls: midrolls,
                               currentTime: 12.0,
                               hasActiveAds: false,
                               isPlayMidrollAllowed: true)
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.VRMCore.AdRequest(url: midroll.url,
                                                      id: midroll.id,
                                                      type: .midroll))
        }
    }
    
    func testSeekOverFirstAndSecondMidrolls() {
        let midroll = midrolls[1]
        recorder.record {
            sut.processMidroll(midrolls: midrolls,
                               currentTime: 16.0,
                               hasActiveAds: false,
                               isPlayMidrollAllowed: true)
            
            var dropped = midrolls
            dropped.remove(at: 1)
            sut.processMidroll(midrolls: dropped,
                               currentTime: 17.0,
                               hasActiveAds: false,
                               isPlayMidrollAllowed: true)
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.VRMCore.AdRequest(url: midroll.url,
                                                      id: midroll.id,
                                                      type: .midroll))
        }
    }
    
    func testSeekOverAllMidrollsAndSeekBack() {
        let firstMidroll = midrolls[1]
        let lastMidroll = midrolls[2]
        recorder.record {
            sut.processMidroll(midrolls: midrolls,
                               currentTime: 21.0,
                               hasActiveAds: false,
                               isPlayMidrollAllowed: true)
            
            var dropped = midrolls
            dropped.remove(at: 2)
            sut.processMidroll(midrolls: dropped,
                               currentTime: 15.0,
                               hasActiveAds: false,
                               isPlayMidrollAllowed: true)
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.VRMCore.AdRequest(url: lastMidroll.url,
                                                      id: lastMidroll.id,
                                                      type: .midroll))
            sut.dispatch(PlayerCore.VRMCore.AdRequest(url: firstMidroll.url,
                                                      id: firstMidroll.id,
                                                      type: .midroll))
        }
    }
}
