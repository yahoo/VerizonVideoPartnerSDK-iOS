//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class VRMMidrollProcessorControllerTest: XCTestCase {
    
    let url = URL(string: "test")!
    let recorder = Recorder()
    let requestID = UUID()
    let midrolls: [PlayerCore.Ad.Midroll] = [.init(cuePoint: 10, url: URL(string: "http://some_url_1")!, id: UUID()),
                                             .init(cuePoint: 15, url: URL(string: "http://some_url_2")!, id: UUID()),
                                             .init(cuePoint: 20, url: URL(string: "http://some_url_3")!, id: UUID())]
    
    let midrollsInSameCuePoint: [PlayerCore.Ad.Midroll] = [.init(cuePoint: 5, url: URL(string: "http://some_url_1")!, id: UUID()),
                                                           .init(cuePoint: 5, url: URL(string: "http://some_url_2")!, id: UUID()),
                                                           .init(cuePoint: 7, url: URL(string: "http://some_url_3")!, id: UUID())]
    
    var sut: VRMMidrollProcessorController!
    
    override func setUp() {
        super.setUp()
        let actionComparator = ActionComparator<VRMCore.AdRequest> {
            $0.type == $1.type && $0.url == $1.url && $0.id == $1.id
        }
        let dispatch = recorder.hook("dispatch", cmp: actionComparator.compare)
        
        sut = VRMMidrollProcessorController(dispatch: dispatch)
    }
    
    override func tearDown() {
        recorder.verify {}
        recorder.clean()
        super.tearDown()
    }
    
    func testDiffSessionsMidroll() {
        recorder.record {
            sut.process(midrolls: midrolls,
                        currentTime: 10,
                        hasActiveAds: false,
                        isPlayMidrollAllowed: true,
                        sessionID: UUID())
            
            sut.process(midrolls: midrolls,
                        currentTime: 11,
                        hasActiveAds: false,
                        isPlayMidrollAllowed: true,
                        sessionID: UUID())
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.VRMCore.AdRequest(url: midrolls[0].url,
                                                      id: midrolls[0].id,
                                                      type: .midroll))
            sut.dispatch(PlayerCore.VRMCore.AdRequest(url: midrolls[0].url,
                                                      id: midrolls[0].id,
                                                      type: .midroll))
        }
    }
    
    func testTimeToPlayMidroll() {
        let midroll = midrolls[0]
        recorder.record {
            let sessionID = UUID()
            sut.process(midrolls: midrolls,
                        currentTime: 10.0,
                        hasActiveAds: false,
                        isPlayMidrollAllowed: true,
                        sessionID: sessionID)
            
            sut.process(midrolls: midrolls,
                        currentTime: 14.0,
                        hasActiveAds: false,
                        isPlayMidrollAllowed: true,
                        sessionID: sessionID)
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
            sut.process(midrolls: midrolls,
                        currentTime: 12.0,
                        hasActiveAds: false,
                        isPlayMidrollAllowed: true,
                        sessionID: UUID())
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
            let sessionID = UUID()
            sut.process(midrolls: midrolls,
                        currentTime: 16.0,
                        hasActiveAds: false,
                        isPlayMidrollAllowed: true,
                        sessionID: sessionID)
            
            var dropped = midrolls
            dropped.remove(at: 1)
            sut.process(midrolls: dropped,
                        currentTime: 17.0,
                        hasActiveAds: false,
                        isPlayMidrollAllowed: true,
                        sessionID: sessionID)
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
            let sessionID = UUID()
            sut.process(midrolls: midrolls,
                        currentTime: 21.0,
                        hasActiveAds: false,
                        isPlayMidrollAllowed: true,
                        sessionID: sessionID)
            
            var dropped = midrolls
            dropped.remove(at: 2)
            sut.process(midrolls: dropped,
                        currentTime: 15.0,
                        hasActiveAds: false,
                        isPlayMidrollAllowed: true,
                        sessionID: sessionID)
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
    
    func testTwoMidrollsInOneCuePoint() {
        recorder.record {
            let sessionID = UUID()
            sut.process(midrolls: midrollsInSameCuePoint,
                        currentTime: 5,
                        hasActiveAds: false,
                        isPlayMidrollAllowed: true,
                        sessionID: sessionID)
            var dropped = midrollsInSameCuePoint
            dropped.remove(at: 0)
            
            sut.process(midrolls: dropped,
                        currentTime: 5,
                        hasActiveAds: false,
                        isPlayMidrollAllowed: true,
                        sessionID: sessionID)
            
            sut.process(midrolls: dropped,
                        currentTime: 6,
                        hasActiveAds: false,
                        isPlayMidrollAllowed: true,
                        sessionID: sessionID)
            
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.VRMCore.AdRequest(url: midrollsInSameCuePoint[0].url,
                                                      id: midrollsInSameCuePoint[0].id,
                                                      type: .midroll))
        }
    }
    
    func testTwoMidrollsInOneCuePointSeekBack() {
        recorder.record {
            let sessionID = UUID()
            sut.process(midrolls: midrollsInSameCuePoint,
                        currentTime: 5,
                        hasActiveAds: false,
                        isPlayMidrollAllowed: true,
                        sessionID: sessionID)
            
            var dropped = midrollsInSameCuePoint
            dropped.remove(at: 0)
            
            sut.process(midrolls: dropped,
                        currentTime: 6,
                        hasActiveAds: false,
                        isPlayMidrollAllowed: true,
                        sessionID: sessionID)
            
            sut.process(midrolls: dropped,
                        currentTime: 3,
                        hasActiveAds: false,
                        isPlayMidrollAllowed: true,
                        sessionID: sessionID)
            
            sut.process(midrolls: dropped,
                        currentTime: 5,
                        hasActiveAds: false,
                        isPlayMidrollAllowed: true,
                        sessionID: sessionID)
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.VRMCore.AdRequest(url: midrollsInSameCuePoint[0].url,
                                                      id: midrollsInSameCuePoint[0].id,
                                                      type: .midroll))
            
            sut.dispatch(PlayerCore.VRMCore.AdRequest(url: midrollsInSameCuePoint[1].url,
                                                      id: midrollsInSameCuePoint[1].id,
                                                      type: .midroll))
        }
    }
}
