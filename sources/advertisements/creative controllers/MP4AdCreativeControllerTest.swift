//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class MP4AdCreativeControllerTest: XCTestCase {

    let recorder = Recorder()
    var sut: MP4AdCreativeController!
    var id: UUID!
    
    
    override func setUp() {
        let comparator = ActionComparator<ShowMP4Ad> {
            $0.creative == $1.creative && $0.id == $1.id
        }
        let dispatch = recorder.hook("hook", cmp: comparator.compare)
        sut = MP4AdCreativeController(dispatch: dispatch)
        id = UUID()
    }
    
    func testSingleMP4Creative() {
        recorder.record {
            sut.process(adCreative: .mp4([getMP4Creative(width: 320, height: 240)]),
                        viewport: CGSize(width: 480, height: 320),
                        id: id)
            sut.process(adCreative: .mp4([getMP4Creative(width: 320, height: 240)]),
                        viewport: CGSize(width: 480, height: 320),
                        id: UUID())
            
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.ShowMP4Ad(creative: getMP4Creative(width: 320, height: 240), id: id))
        }
    }
    
    func testIncorectCreative() {
        recorder.record {
            sut.process(adCreative: .none, viewport: CGSize(width: 480, height: 320), id: id)
            sut.process(adCreative: .vpaid([getVPAIDCreative()]), viewport: CGSize(width: 480, height: 320), id: id)
        }
        
        recorder.verify {}
    }
    
    func testDispatchAppropriateAdBySize() {
        recorder.record {
            sut.process(adCreative: .mp4([getMP4Creative(width: 640, height: 480),
                                          getMP4Creative(width: 640, height: 360),
                                          getMP4Creative(width: 320, height: 180)]),
                        viewport: CGSize(width: 520, height: 380),
                        id: id)
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.ShowMP4Ad(creative: getMP4Creative(width: 640, height: 360), id: id))
        }
    }
    
    func testDispatchTheSmallestAdBySize() {
        recorder.record {
            sut.process(adCreative: .mp4([getMP4Creative(width: 640, height: 480),
                                          getMP4Creative(width: 640, height: 360),
                                          getMP4Creative(width: 320, height: 180)]),
                        viewport: CGSize(width: 240, height: 160),
                        id: id)
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.ShowMP4Ad(creative: getMP4Creative(width: 320, height: 180), id: id))
        }
    }
    
    func testDispatchTheBiggestAdBySize() {
        recorder.record {
            sut.process(adCreative: .mp4([getMP4Creative(width: 640, height: 480),
                                          getMP4Creative(width: 640, height: 360),
                                          getMP4Creative(width: 320, height: 180)]),
                        viewport: CGSize(width: 896, height: 414),
                        id: id)
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.ShowMP4Ad(creative: getMP4Creative(width: 640, height: 480), id: id))
        }
    }
}
