//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK

class ErrorDetectorTests: XCTestCase {
    
    var recorder: Recorder!
    var sut: Detectors.ErrorDetector!
    
    enum TestErrorType: Error { case Error }
    
    var testError = NSError(domain:"TestDomain", code:111, userInfo:nil)
    var didDetect: Action<NSError>!
    
    override func setUp() {
        super.setUp()
        
        recorder = Recorder()
        sut = Detectors.ErrorDetector()
        didDetect = recorder.hook("errorDetectorTests")
    }
    
    override func tearDown() {
        recorder.verify { }
        recorder = nil
        sut = nil
        didDetect = nil
        
        super.tearDown()
    }
    
    func testInitial() {
        recorder.record {
            sut.process(error: nil, onDetect: didDetect)
        }
        
        recorder.verify { }
    }
    
    func testErrorDetect() {
        
        recorder.record {
            sut.process(error: TestErrorType.Error, onDetect: didDetect)
        }
        
        recorder.verify {
            didDetect(TestErrorType.Error as NSError)
        }
    }
    
    func testCoupleCallOfSingError() {
        recorder.record {
            sut.process(error: testError, onDetect: didDetect)
            sut.process(error: testError, onDetect: didDetect)
        }
        
        recorder.verify {
            didDetect(testError)
        }
    }
    
    func testDifferentErrors() {
        
        recorder.record {
            sut.process(error: TestErrorType.Error, onDetect: didDetect)
            sut.process(error: testError, onDetect: didDetect)
        }
        
        recorder.verify {
            didDetect(TestErrorType.Error as NSError)
            didDetect(testError)
        }
    }
    
    
    func testDifferentErrorsCoupleTimes() {
        recorder.record {
            sut.process(error: TestErrorType.Error, onDetect: didDetect)
            sut.process(error: TestErrorType.Error, onDetect: didDetect)
            sut.process(error: testError, onDetect: didDetect)
            sut.process(error: testError, onDetect: didDetect)
        }
        
        recorder.verify {
            didDetect(TestErrorType.Error as NSError)
            didDetect(testError)
        }
    }
}
