//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK

class BufferingStartTests: XCTestCase {
    
    var sut: Detectors.BufferingStart!
    var recorder :Recorder! = nil
    var didDetect: ActionWithVoid!
    
    override func setUp() {
        super.setUp()
        
        sut = Detectors.BufferingStart()
        recorder = Recorder()
        didDetect = recorder.hook("BufferingStart")
    }
    
    override func tearDown() {
        recorder = nil
        sut = nil
        super.tearDown()
    }
    
    func testPlaybackUnavailable() {
        recorder.record {
            sut.process(adIsBuffering: false, contentIsBuffering: false, onDetect:  didDetect)
        }
        
        recorder.verify { }
    }
    
    func testAdBuffering() {
        recorder.record {
            sut.process(adIsBuffering: true, contentIsBuffering: false, onDetect: didDetect)
        }
        
        recorder.verify {
            didDetect()
        }
    }
    
    func testContentBuffering() {
        recorder.record {
            sut.process(adIsBuffering: false, contentIsBuffering: true, onDetect: didDetect)
        }
        
        recorder.verify {
            didDetect()
        }
    }
    
    func testMultipleCalls() {
        recorder.record {
            sut.process(adIsBuffering: false, contentIsBuffering: true, onDetect: didDetect)
            sut.process(adIsBuffering: false, contentIsBuffering: true, onDetect: didDetect)
            sut.process(adIsBuffering: false, contentIsBuffering: true, onDetect: didDetect)
        }
        
        recorder.verify {
            didDetect()
        }
    }
    
    func testAdThenContent() {
        recorder.record {
            sut.process(adIsBuffering: true, contentIsBuffering: false, onDetect: didDetect)
            sut.process(adIsBuffering: false, contentIsBuffering: false, onDetect: didDetect)
            sut.process(adIsBuffering: false, contentIsBuffering: true, onDetect: didDetect)
        }
        
        recorder.verify {
            didDetect()
            didDetect()
        }
    }
}
