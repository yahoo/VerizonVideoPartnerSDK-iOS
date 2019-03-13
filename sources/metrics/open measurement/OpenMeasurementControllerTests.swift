//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import PlayerCore
@testable import VerizonVideoPartnerSDK

class OpenMeasurementComponentTestCase: XCTestCase {
    
    var recorder: Recorder!
    var controller: VerizonVideoPartnerSDK.OpenMeasurement.AdSessionController!
    var dispatcher: ((PlayerCore.Action) -> Void)!
    var adVerifications = [PlayerCore.Ad.VASTModel.AdVerification]()
    
    var adSession: OMAdSessionMock!
    
    let adEvents = PlayerCore.OpenMeasurement.AdEvents.empty
    let videoEvents = PlayerCore.OpenMeasurement.VideoEvents.empty
    let adView = UIView(frame: .zero)
    typealias OMErrors = VerizonVideoPartnerSDK.OpenMeasurement.Errors
    
    override func setUp() {
        super.setUp()
        recorder = Recorder()
        let testUrl = URL(string: "http://test.com")!
        adVerifications = [Ad.VASTModel.AdVerification(vendorKey: "TestApp",
                                                     javaScriptResource: testUrl,
                                                     verificationParameters: testUrl,
                                                     verificationNotExecuted: testUrl)]
        dispatcher = recorder.hook("dispatcher") { target, record in
            switch (target, record) {
            case (is OpenMeasurementActivated, is OpenMeasurementActivated):
                return true
            case (let targetAction as OpenMeasurementConfigurationFailed, let recordAction as OpenMeasurementConfigurationFailed):
                return targetAction.error.localizedDescription == recordAction.error.localizedDescription
            case (is OpenMeasurementDeactivated, is OpenMeasurementDeactivated):
                return true
            default: return false
            }
        }
        controller = VerizonVideoPartnerSDK.OpenMeasurement.AdSessionController(
            adViewAction: { [weak self] in self?.adView },
            createOMContext: createContext,
            dispatcher: dispatcher)
        controller.serviceScript = "{}"
        
        adSession = OMAdSessionMock()
    }
    
    override func tearDown() {
        recorder.verify { }
        recorder = nil
        
        super.tearDown()
    }
    
    func testInitial() {
        recorder.record {
            controller.process(with: .inactive)
        }
        
        recorder.verify { }
        XCTAssertFalse(adSession.isStarted)
        XCTAssertFalse(adSession.isFinished)
    }
    func testFailedAndDisabledState() {
        recorder.record {
            controller.process(with: .failed(OMErrors.failedToActivateSDK))
            controller.process(with: .disabled)
        }
        
        recorder.verify { }
        XCTAssertFalse(adSession.isStarted)
        XCTAssertFalse(adSession.isFinished)
    }
    func testNoScriptAvailable() {
        recorder.record {
            controller.serviceScript = nil
            controller.process(with: .loading)
        }
        
        recorder.verify {
            dispatcher(PlayerCore.failedOMConfiguration(with: OMErrors.scriptNotAvailable))
        }
        XCTAssertFalse(adSession.isStarted)
        XCTAssertFalse(adSession.isFinished)
    }
    func testActivatedSuccessfully() {
        recorder.record {
            controller.process(with: .readyForLoad(adVerifications))
            controller.process(with: .loading)
        }
        
        recorder.verify {
            dispatcher(PlayerCore.openMeasurementActivated(adEvents: adEvents,
                                                           videoEvents: videoEvents))
        }
        XCTAssertTrue(adSession.isStarted)
        XCTAssertFalse(adSession.isFinished)
        XCTAssertNotNil(adSession.mainAdView)
    }
    func testActivatedState() {
        controller.process(with: .readyForLoad(adVerifications))
        controller.process(with: .loading)
        
        recorder.record {
            controller.process(with: .active(adEvents, videoEvents))
        }
        
        recorder.verify { }
        XCTAssertTrue(adSession.isStarted)
        XCTAssertFalse(adSession.isFinished)
    }
    func testShouldNotBeFinished() {
        controller.process(with: .readyForLoad(adVerifications))
        controller.process(with: .loading)
        
        recorder.record {
            controller.process(with: .finished(adEvents,videoEvents))
        }
        
        recorder.verify {
            dispatcher(PlayerCore.openMeasurementDeactivated())
        }
        XCTAssertTrue(adSession.isStarted)
        XCTAssertFalse(adSession.isFinished)
    }
    func testShouldBeFinished() {
        controller.process(with: .readyForLoad(adVerifications))
        controller.process(with: .loading)
        controller.process(with: .finished(adEvents,videoEvents))
        controller.process(with: .inactive)
        XCTAssertTrue(adSession.isStarted)
        XCTAssertTrue(adSession.isFinished)
    }
    
    func testWithFailedConfiguration() {
        func createFailedContext(input: VerizonVideoPartnerSDK.OpenMeasurement.Input) throws -> VerizonVideoPartnerSDK.OpenMeasurement.Output {
            throw OMErrors.failedToActivateSDK
        }
        controller = VerizonVideoPartnerSDK.OpenMeasurement.AdSessionController(
            adViewAction: { return UIView(frame: .zero) },
            createOMContext: createFailedContext,
            dispatcher: dispatcher)
        controller.serviceScript = "{}"
        
        recorder.record {
            controller.process(with: .readyForLoad(adVerifications))
            controller.process(with: .loading)
        }
        
        recorder.verify {
            dispatcher(PlayerCore.failedOMConfiguration(with: OMErrors.failedToActivateSDK))
        }
        XCTAssertFalse(adSession.isStarted)
        XCTAssertFalse(adSession.isFinished)
    }
    func testWithNoAdView() {
        controller = VerizonVideoPartnerSDK.OpenMeasurement.AdSessionController(
            adViewAction: { return nil },
            createOMContext: createContext,
            dispatcher: dispatcher)
        controller.serviceScript = "{}"
        
        recorder.record {
            controller.process(with: .readyForLoad(adVerifications))
            controller.process(with: .loading)
        }
        
        recorder.verify {
        }
        
        XCTAssertFalse(adSession.isStarted)
        XCTAssertFalse(adSession.isFinished)
    }
    func createContext(input: VerizonVideoPartnerSDK.OpenMeasurement.Input) throws -> VerizonVideoPartnerSDK.OpenMeasurement.Output {
        return VerizonVideoPartnerSDK.OpenMeasurement.Output(adSession: adSession,
                                                   adEvents: adEvents,
                                                   videoEvents: videoEvents)
    }
    
    final class OMAdSessionMock: OpenMeasurementAdSessionProtocol {
        weak var mainAdView: UIView?
        
        var isStarted = false
        var isFinished = false
        
        func start() { isStarted = true }
        func finish() { isFinished = true }
    }
}

