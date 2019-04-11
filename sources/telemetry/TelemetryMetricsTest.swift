//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import CoreMedia
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
    
    var vrmProcessing: Telemetry.Metrics.Buffering.VRM!
    var mp4AdBuffering: Telemetry.Metrics.Buffering.MP4Ad!
    var contentBuffering:  Telemetry.Metrics.Buffering.Content!
    
    var abuseTelemetry: Telemetry.Metrics.VPAID.AbuseEventErrorReporter!
    var jsTelemetry: Telemetry.Metrics.VPAID.JSEvaluationErrorReporter!
    var unsupportedVPAID: Telemetry.Metrics.VPAID.UnsupportedVPAIDReporter!
    
    override func setUp() {
        super.setUp()
        
        func compareJSON(target: Telemetry.TelemetryJSON, recorded: Telemetry.TelemetryJSON) -> Bool {
            return target.data == recorded.data
        }
        
        let send = recorder.hook("hook", cmp: compareJSON)
        abuseTelemetry = Telemetry.Metrics.VPAID.AbuseEventErrorReporter(context: [:], send: send)
        jsTelemetry = Telemetry.Metrics.VPAID.JSEvaluationErrorReporter(context: [:], send: send)
        unsupportedVPAID = Telemetry.Metrics.VPAID.UnsupportedVPAIDReporter(context: [:], send: send)
        adStartTimeout = Telemetry.Metrics.AdStartTimeout(context: [:], send: send)
        successInitializationReporter = Telemetry.Metrics.OpenMeasurement.SuccessInitializationReporter(context: [:], send: send)
        failedConfigurationReporter = Telemetry.Metrics.OpenMeasurement.FailedConfigurationReporter(context: [:], send: send)
        scriptFetchingFailedReporter = Telemetry.Metrics.OpenMeasurement.ScriptFetchingFailedReporter(context: [:], send: send)
        vrmProcessing = Telemetry.Metrics.Buffering.VRM(context: [:], send: send)
        mp4AdBuffering = Telemetry.Metrics.Buffering.MP4Ad(context: [:], send: send)
        contentBuffering = Telemetry.Metrics.Buffering.Content(context: [:], send: send)
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
            abuseTelemetry.send(telemetryJSON(for: "VPAID_UNIQUE_EVENT_ABUSE",
                                              and: ["event_name": "AdImpression" |> json,
                                                    "rid": "rule id" |> json]))
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
            abuseTelemetry.send(telemetryJSON(for: "VPAID_UNIQUE_EVENT_ABUSE",
                                              and: ["event_name": "AdImpression" |> json,
                                                    "rid": "rule id" |> json]))
            abuseTelemetry.send(telemetryJSON(for: "VPAID_UNIQUE_EVENT_ABUSE",
                                              and: ["event_name": "AdStart" |> json,
                                                    "rid": "rule id" |> json]))
        }
    }
    
    func testSameEventDiffRuleId() {
        let error = eventErrorWithName(name: "AdImpression")
        
        recorder.record {
            abuseTelemetry.process(abusedEvents: [error], forRuleId: "rule id 1")
            abuseTelemetry.process(abusedEvents: [error, error], forRuleId: "rule id 2")
        }
        
        recorder.verify {
            abuseTelemetry.send(telemetryJSON(for: "VPAID_UNIQUE_EVENT_ABUSE",
                                              and: ["event_name": "AdImpression" |> json,
                                                    "rid": "rule id 1" |> json]))
            abuseTelemetry.send(telemetryJSON(for: "VPAID_UNIQUE_EVENT_ABUSE",
                                              and: ["event_name": "AdImpression" |> json,
                                                    "rid": "rule id 2" |> json]))
        }
    }
    
    func testJSErrorSameSession() {
        let error = TestError(name: "error")
        
        recorder.record {
            jsTelemetry.process(javascriptErrors: [error], forRuleId: "rule")
            jsTelemetry.process(javascriptErrors: [error, error], forRuleId: "rule")
        }
        
        recorder.verify {
            jsTelemetry.send(telemetryJSON(for: "VPAID_JAVASCRIPT_EVALUATION_ERROR",
                                           and: ["rid": "rule" |> json,
                                                 "error_code": "\(error.errorCode)" |> json,
                                                 "error_description": (error as NSError).description |> json,
                                                 "error_additional_info": error.errorUserInfo.description |> json]))
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
            jsTelemetry.send(telemetryJSON(for: "VPAID_JAVASCRIPT_EVALUATION_ERROR",
                                           and: ["rid": "rule1" |> json,
                                                 "error_code": "\(error1.errorCode)" |> json,
                                                 "error_description": (error1 as NSError).description |> json,
                                                 "error_additional_info": error1.errorUserInfo.description |> json]))
            
            jsTelemetry.send(telemetryJSON(for: "VPAID_JAVASCRIPT_EVALUATION_ERROR",
                                           and: ["rid": "rule2" |> json,
                                                 "error_code": "\(error2.errorCode)" |> json,
                                                 "error_description": (error2 as NSError).description |> json,
                                                 "error_additional_info": error2.errorUserInfo.description |> json]))
            
            jsTelemetry.send(telemetryJSON(for: "VPAID_JAVASCRIPT_EVALUATION_ERROR",
                                           and: ["rid": "rule2" |> json,
                                                 "error_code": "\(error3.errorCode)" |> json,
                                                 "error_description": (error3 as NSError).description |> json,
                                                 "error_additional_info": error3.errorUserInfo.description |> json]))
        }
    }
    
    func testUnsupportedVPAIDInSameSession() {
        recorder.record {
            unsupportedVPAID.process(isUnsupported: true, forRuleId: "rule id")
            unsupportedVPAID.process(isUnsupported: true, forRuleId: "rule id")
        }
        
        recorder.verify {
            unsupportedVPAID.send(telemetryJSON(for: "VPAID_UNSUPPORTED_VERSION_ERROR",
                                                and: ["rid": "rule id" |> json]))
        }
    }
    
    func testUnsupportedVPAIDTwoSession() {
        recorder.record {
            unsupportedVPAID.process(isUnsupported: true, forRuleId: "rule 1")
            unsupportedVPAID.process(isUnsupported: true, forRuleId: "rule 2")
            unsupportedVPAID.process(isUnsupported: false, forRuleId: "rule 2")
        }
        
        recorder.verify {
            unsupportedVPAID.send(telemetryJSON(for: "VPAID_UNSUPPORTED_VERSION_ERROR",
                                                and: ["rid": "rule 1" |> json]))
            
            unsupportedVPAID.send(telemetryJSON(for: "VPAID_UNSUPPORTED_VERSION_ERROR",
                                                and: ["rid": "rule 2" |> json]))
        }
    }
    
    func testAdStartTimeout() {
        recorder.record {
            adStartTimeout.process(isTimeoutReached: true, for: "rule 1")
            adStartTimeout.process(isTimeoutReached: true, for: "rule 1")
        }
        
        recorder.verify {
            adStartTimeout.send(telemetryJSON(for: "START_TIMEOUT_REACHED",
                                              and: ["rid": "rule 1" |> json]))
        }
    }
    func testAdStartTimeoutOnSecondSession() {
        recorder.record {
            adStartTimeout.process(isTimeoutReached: false, for: "rule 1")
            adStartTimeout.process(isTimeoutReached: false, for: "rule 2")
            adStartTimeout.process(isTimeoutReached: true, for: "rule 2")
        }
        
        recorder.verify {
            adStartTimeout.send(telemetryJSON(for: "START_TIMEOUT_REACHED",
                                              and: ["rid": "rule 2" |> json]))
        }
    }
    func testAdStartTimeoutTwoSessions() {
        recorder.record {
            adStartTimeout.process(isTimeoutReached: true, for: "rule 1")
            adStartTimeout.process(isTimeoutReached: true, for: "rule 2")
            adStartTimeout.process(isTimeoutReached: false, for: "rule 2")
        }
        
        recorder.verify {
            adStartTimeout.send(telemetryJSON(for: "START_TIMEOUT_REACHED",
                                              and: ["rid": "rule 1" |> json]))
            adStartTimeout.send(telemetryJSON(for: "START_TIMEOUT_REACHED",
                                              and: ["rid": "rule 2" |> json]))
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
            successInitializationReporter.send(telemetryJSON(for: "OM_SDK_INITIATED",
                                                             and: ["rid": "rule 1" |> json]))
            successInitializationReporter.send(telemetryJSON(for: "OM_SDK_INITIATED",
                                                             and: ["rid": "rule 2" |> json]))
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
            failedConfigurationReporter.send(telemetryJSON(for: "OM_SDK_ERROR",
                                                           and: ["message": error.localizedDescription |> json,
                                                                 "rid": "rule 1" |> json]))
            failedConfigurationReporter.send(telemetryJSON(for: "OM_SDK_ERROR",
                                                           and: ["message": error.localizedDescription |> json,
                                                                 "rid": "rule 2" |> json]))
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
            scriptFetchingFailedReporter.send(telemetryJSON(for: "OM_SDK_SCRIPT_FETCHING_FAILED",
                                                            and: ["message": error.localizedDescription |> json]))
        }
    }
    
    func testVRMProcessingFinished() {
        let startAt = Date(timeIntervalSince1970: 0)
        let finishAt = Date(timeIntervalSince1970: 2.5)
        
        recorder.record {
            let adRequest = UUID()
            vrmProcessing.process(requestId: adRequest, processingStatus: .inProgress(startAt: startAt))
            vrmProcessing.process(requestId: adRequest, processingStatus: .finished(startAt: startAt, finishAt: finishAt))
            vrmProcessing.process(requestId: adRequest, processingStatus: .finished(startAt: startAt, finishAt: finishAt))
        }
        
        recorder.verify {
            vrmProcessing.vrm.send(telemetryJSON(for: "VRM_PROCESSING_TIME",
                                                 and: ["time": 2500 |> json]))
        }
    }
    
    func testAdBufferingTime() {
        let startAt = Date(timeIntervalSince1970: 0)
        let finishAt = Date(timeIntervalSince1970: 2.5)
        
        recorder.record {
            let adRequest = UUID()
            mp4AdBuffering.process(requestId: adRequest, processingStatus: .inProgress(startAt: startAt))
            mp4AdBuffering.process(requestId: adRequest, processingStatus: .finished(startAt: startAt, finishAt: finishAt))
            mp4AdBuffering.process(requestId: adRequest, processingStatus: .finished(startAt: startAt, finishAt: finishAt))
        }
        
        recorder.verify {
            mp4AdBuffering.mp4Ad.send(telemetryJSON(for: "AD_BUFFERING_TIME",
                                                    and: ["time": 2500 |> json]))
        }
    }
    
    func testContentBufferingTime() {
        let startAt = Date(timeIntervalSince1970: 0)
        let finishAt = Date(timeIntervalSince1970: 2.5)
        recorder.record {
            let sessionId = UUID()
            contentBuffering.process(playbackSession: sessionId,
                                     processingStatus: .inProgress(startAt: startAt))
            contentBuffering.process(playbackSession: sessionId,
                                     processingStatus: .finished(startAt: startAt, finishAt: finishAt))
            contentBuffering.process(playbackSession: sessionId,
                                     processingStatus: .finished(startAt: startAt, finishAt: finishAt))
        }
        
        recorder.verify {
            contentBuffering.content.send(telemetryJSON(for: "VIDEO_BUFFERING_TIME",
                                                        and: ["time": 2500 |> json]))
        }
    }
    
    private func telemetryJSON(for type: String, and value: [String: JSøN]) -> Telemetry.TelemetryJSON {
        let data: [String: JSøN] = [
            "data" : [
                "type" : type |> json,
                "value": value |> json
                ] |> json
        ]
        return .init(context: [:], data: data |> json)
    }
    
    private func eventErrorWithName(name: String) -> VPAIDErrors.UniqueEventError {
        return VPAIDErrors.UniqueEventError(eventName: name, eventValue: nil)
    }
}
