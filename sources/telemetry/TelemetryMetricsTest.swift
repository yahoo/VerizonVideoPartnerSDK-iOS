//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import PlayerCore
@testable import VerizonVideoPartnerSDK

class TelemetryMetricsTest: XCTestCase {
    
    public struct TestError: CustomNSError {
        let name: String
        
        var errorUserInfo: [String : Any] {
            return [NSLocalizedDescriptionKey : name]
        }
    }
    
    let recorder = Recorder()
    var adStartTimeout: Telemetry.Metrics.AdStartTimeout!
    
    var successInitializationReporter: Telemetry.Metrics.OpenMeasurement.SuccessInitializationReporter!
    var failedConfigurationReporter: Telemetry.Metrics.OpenMeasurement.FailedConfigurationReporter!
    var scriptFetchingFailedReporter: Telemetry.Metrics.OpenMeasurement.ScriptFetchingFailedReporter!

    var vrmProcessing: Telemetry.Metrics.VRMProcessing!
    
    var abuseTelemetry: Telemetry.Metrics.VPAID.AbuseEventErrorReporter!
    var jsTelemetry: Telemetry.Metrics.VPAID.JSEvaluationErrorReporter!
    var unsupportedVPAID: Telemetry.Metrics.VPAID.UnsupportedVPAIDReporter!
    
    override func setUp() {
        super.setUp()
        
        func compareJSON(target: JSON, recorded: JSON) -> Bool {
            let targetJSONkeys = target.keys
            let recordedJSONkeys = recorded.keys
            guard targetJSONkeys.elementsEqual(recordedJSONkeys) else { return false }
            let targetDictionary = target as NSDictionary
            let recordedDictionary = recorded as NSDictionary
            return targetDictionary.isEqual(recordedDictionary)
        }
        
        let send = recorder.hook("hook", cmp: compareJSON)
        abuseTelemetry = Telemetry.Metrics.VPAID.AbuseEventErrorReporter(context: [:], send: send)
        jsTelemetry = Telemetry.Metrics.VPAID.JSEvaluationErrorReporter(context: [:], send: send)
        unsupportedVPAID = Telemetry.Metrics.VPAID.UnsupportedVPAIDReporter(context: [:], send: send)
        adStartTimeout = Telemetry.Metrics.AdStartTimeout(context: [:], send: send)
        successInitializationReporter = Telemetry.Metrics.OpenMeasurement.SuccessInitializationReporter(context: [:], send: send)
        failedConfigurationReporter = Telemetry.Metrics.OpenMeasurement.FailedConfigurationReporter(context: [:], send: send)
        scriptFetchingFailedReporter = Telemetry.Metrics.OpenMeasurement.ScriptFetchingFailedReporter(context: [:], send: send)
        vrmProcessing = Telemetry.Metrics.VRMProcessing(context: [:], send: send)
    }
    
    override func tearDown() {
        recorder.clean()
        super.tearDown()
    }
    
    func testSameEventForSameRuleId() {
        let error = eventErrorWithName(name: "AdImpression")
        recorder.record {
            abuseTelemetry.process(abusedEvents: [error], forRuleId: "rule id")
            abuseTelemetry.process(abusedEvents: [error, error], forRuleId: "rule id")
        }
        
        recorder.verify {
            abuseTelemetry.send(json(for: "VPAID_UNIQUE_EVENT_ABUSE",
                                     and: ["event_name": "AdImpression",
                                           "rid": "rule id"]))
        }
    }
    
    func testDiffEventForSameRuleId() {
        let adImpression = eventErrorWithName(name: "AdImpression")
        let adStart = eventErrorWithName(name: "AdStart")
        
        recorder.record {
            abuseTelemetry.process(abusedEvents: [adImpression], forRuleId: "rule id")
            abuseTelemetry.process(abusedEvents: [adImpression, adStart], forRuleId: "rule id")
        }
        
        recorder.verify {
            abuseTelemetry.send(json(for: "VPAID_UNIQUE_EVENT_ABUSE",
                                     and: ["event_name": "AdImpression",
                                           "rid": "rule id"]))
            abuseTelemetry.send(json(for: "VPAID_UNIQUE_EVENT_ABUSE",
                                     and: ["event_name": "AdStart",
                                           "rid": "rule id"]))
        }
    }
    
    func testSameEventDiffRuleId() {
        let error = eventErrorWithName(name: "AdImpression")
        
        recorder.record {
            abuseTelemetry.process(abusedEvents: [error], forRuleId: "rule id 1")
            abuseTelemetry.process(abusedEvents: [error, error], forRuleId: "rule id 2")
        }
        
        recorder.verify {
            abuseTelemetry.send(json(for: "VPAID_UNIQUE_EVENT_ABUSE",
                                     and: ["event_name": "AdImpression",
                                           "rid": "rule id 1"]))
            abuseTelemetry.send(json(for: "VPAID_UNIQUE_EVENT_ABUSE",
                                     and: ["event_name": "AdImpression",
                                           "rid": "rule id 2"]))
        }
    }
    
    func testJSErrorSameSession() {
        let error = TestError(name: "error")

        recorder.record {
            jsTelemetry.process(javascriptErrors: [error], forRuleId: "rule")
            jsTelemetry.process(javascriptErrors: [error, error], forRuleId: "rule")
        }
        
        recorder.verify {
            jsTelemetry.send(json(for: "VPAID_JAVASCRIPT_EVALUATION_ERROR",
                                  and: ["rid": "rule",
                                        "error_code": "\(error.errorCode)",
                                        "error_description": (error as NSError).description,
                                        "error_additional_info": error.errorUserInfo]))
        }
    }
    
    func testJSErrorsInDiffSessions() {
        let error1 = TestError(name: "error1")
        let error2 = TestError(name: "error2")
        let error3 = TestError(name: "error3")

        recorder.record {
            jsTelemetry.process(javascriptErrors: [error1], forRuleId: "rule1")
            jsTelemetry.process(javascriptErrors: [error2, error3], forRuleId: "rule2")
        }

        recorder.verify {
            jsTelemetry.send(json(for: "VPAID_JAVASCRIPT_EVALUATION_ERROR",
                                  and: ["rid": "rule1",
                                        "error_code": "\(error1.errorCode)",
                                    "error_description": (error1 as NSError).description,
                                    "error_additional_info": error1.errorUserInfo]))
            
            jsTelemetry.send(json(for: "VPAID_JAVASCRIPT_EVALUATION_ERROR",
                                  and: ["rid": "rule2",
                                        "error_code": "\(error2.errorCode)",
                                    "error_description": (error2 as NSError).description,
                                    "error_additional_info": error2.errorUserInfo]))
            
            jsTelemetry.send(json(for: "VPAID_JAVASCRIPT_EVALUATION_ERROR",
                                  and: ["rid": "rule2",
                                        "error_code": "\(error3.errorCode)",
                                    "error_description": (error3 as NSError).description,
                                    "error_additional_info": error3.errorUserInfo]))
        }
    }
    
    func testUnsupportedVPAIDInSameSession() {
        recorder.record {
            unsupportedVPAID.process(isUnsupported: true, forRuleId: "rule id")
            unsupportedVPAID.process(isUnsupported: true, forRuleId: "rule id")
        }
        
        recorder.verify {
            unsupportedVPAID.send(json(for: "VPAID_UNSUPPORTED_VERSION_ERROR",
                                       and: ["rid": "rule id"]))
        }
    }
    
    func testUnsupportedVPAIDTwoSession() {
        recorder.record {
            unsupportedVPAID.process(isUnsupported: true, forRuleId: "rule 1")
            unsupportedVPAID.process(isUnsupported: true, forRuleId: "rule 2")
            unsupportedVPAID.process(isUnsupported: false, forRuleId: "rule 2")
        }
        
        recorder.verify {
            unsupportedVPAID.send(json(for: "VPAID_UNSUPPORTED_VERSION_ERROR",
                                       and: ["rid": "rule 1"]))
            
            unsupportedVPAID.send(json(for: "VPAID_UNSUPPORTED_VERSION_ERROR",
                                       and: ["rid": "rule 2"]))
        }
    }
    
    func testAdStartTimeout() {
        recorder.record {
            adStartTimeout.process(isTimeoutReached: true, for: "rule 1")
            adStartTimeout.process(isTimeoutReached: true, for: "rule 1")
        }
        
        recorder.verify {
            adStartTimeout.send(json(for: "START_TIMEOUT_REACHED",
                                       and: ["rid": "rule 1"]))
        }
    }
    func testAdStartTimeoutOnSecondSession() {
        recorder.record {
            adStartTimeout.process(isTimeoutReached: false, for: "rule 1")
            adStartTimeout.process(isTimeoutReached: false, for: "rule 2")
            adStartTimeout.process(isTimeoutReached: true, for: "rule 2")
        }
        
        recorder.verify {
            adStartTimeout.send(json(for: "START_TIMEOUT_REACHED",
                                     and: ["rid": "rule 2"]))
        }
    }
    func testAdStartTimeoutTwoSessions() {
        recorder.record {
            adStartTimeout.process(isTimeoutReached: true, for: "rule 1")
            adStartTimeout.process(isTimeoutReached: true, for: "rule 2")
            adStartTimeout.process(isTimeoutReached: false, for: "rule 2")
        }
        
        recorder.verify {
            adStartTimeout.send(json(for: "START_TIMEOUT_REACHED",
                                       and: ["rid": "rule 1"]))
            adStartTimeout.send(json(for: "START_TIMEOUT_REACHED",
                                       and: ["rid": "rule 2"]))
        }
    }
    func testOpenMeasurementInitiated() {
        recorder.record {
            successInitializationReporter.process(isMeasurementStarted: true, forRuleId: "rule 1")
            successInitializationReporter.process(isMeasurementStarted: true, forRuleId: "rule 1")
            successInitializationReporter.process(isMeasurementStarted: false, forRuleId: "rule 2")
            successInitializationReporter.process(isMeasurementStarted: true, forRuleId: "rule 2")
        }
        
        recorder.verify {
            successInitializationReporter.send(json(for: "OM_SDK_INITIATED",
                                                    and: ["rid": "rule 1"]))
            successInitializationReporter.send(json(for: "OM_SDK_INITIATED",
                                                    and: ["rid": "rule 2"]))
        }
    }
    func testOpenMeasurementFailed() {
        enum Errors: Swift.Error { case failedToActivateSDK }
        let error = Errors.failedToActivateSDK
        
        recorder.record {
            failedConfigurationReporter.process(with: nil, forRuleId: "rule 1")
            failedConfigurationReporter.process(with: error, forRuleId: "rule 1")
            failedConfigurationReporter.process(with: error, forRuleId: "rule 2")
            failedConfigurationReporter.process(with: error, forRuleId: "rule 2")
        }
        
        recorder.verify {
            failedConfigurationReporter.send(json(for: "OM_SDK_ERROR",
                                                  and: ["message": error.localizedDescription,
                                                        "rid": "rule 1"]))
            failedConfigurationReporter.send(json(for: "OM_SDK_ERROR",
                                                  and: ["message": error.localizedDescription,
                                                        "rid": "rule 2"]))
        }
    }
    func testServiceScriptFetchingFailed() {
        enum Errors: Swift.Error { case fetchingFailed }
        let error = Errors.fetchingFailed
        
        recorder.record {
            scriptFetchingFailedReporter.process(with: nil)
            scriptFetchingFailedReporter.process(with: error)
            scriptFetchingFailedReporter.process(with: error)
        }
        
        recorder.verify {
            scriptFetchingFailedReporter.send(json(for: "OM_SDK_SCRIPT_FETCHING_FAILED",
                                                  and: ["message": error.localizedDescription]))
        }
    }
    
    func testVRMProcessingFinished() {
        let startAt = Date(timeIntervalSince1970: 0)
        let finishAt = Date(timeIntervalSince1970: 2.5)
        
        recorder.record {
            let adRequest = UUID()
            vrmProcessing.process(adRequest: adRequest, processingTime: .inProgress(startAt: startAt))
            vrmProcessing.process(adRequest: adRequest, processingTime: .finished(startAt: startAt, finishAt: finishAt))
            vrmProcessing.process(adRequest: adRequest, processingTime: .finished(startAt: startAt, finishAt: finishAt))
        }
        
        recorder.verify {
            vrmProcessing.send(json(for: "VRM_PROCESSING_TIME",
                                    and: ["time": 2500]))
        }
    }
    
    private func json(for name: String, and value: JSON) -> JSON {
        return  [
            "context" : [:],
            "data" : [
                "type" : name,
                "value": value
            ]
        ]
    }
    
    private func eventErrorWithName(name: String) -> VPAIDErrors.UniqueEventError {
        return VPAIDErrors.UniqueEventError(eventName: name, eventValue: nil)
    }
}
