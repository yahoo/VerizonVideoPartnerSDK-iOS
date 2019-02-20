//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import PlayerCore

extension Telemetry {
    struct Metrics {
        let airPlay: AirPlay
        let subtitles: Subtitles
        let videoProvider: VideoProvider
        let pictureInPicture: PictureInPicture
        let adStartTimeout: AdStartTimeout
        let vpaid: VPAID
        let openMeasurement: OpenMeasurement
        let vrmProcessing: VRMProcessing
        let adBuffering: AdBuffering
        
        init(url: URL, context: JSON, ephemeralSession: URLSession) {
            let send = Telemetry.CustomTelemetrySender(session: ephemeralSession,
                                                       url: url).send
            airPlay = AirPlay(context: context, send: send)
            subtitles = Subtitles(context: context, send: send)
            videoProvider = VideoProvider(context: context, send: send)
            pictureInPicture = PictureInPicture(context: context, send: send)
            adStartTimeout = AdStartTimeout(context: context, send: send)
            vpaid = VPAID(context: context, send: send)
            openMeasurement = OpenMeasurement(context: context, send: send)
            vrmProcessing = VRMProcessing(context: context, send: send)
            adBuffering = AdBuffering(context: context, send: send)
        }
        
        func process(props: Player.Properties) {
            airPlay.process(props: props)
            subtitles.process(props: props)
            pictureInPicture.process(props: props)
        }
        
        func process(state: PlayerCore.State, model: PlayerCore.Model) {
            vpaid.process(state: state)
            adStartTimeout.process(state: state)
            openMeasurement.process(state: state)
            vrmProcessing.process(state: state)
            adBuffering.process(state: state)
        }
        
        func process(videoProviderError error: Error) {
            videoProvider.process(error: error)
        }
    }
}

extension Telemetry.Metrics {
    final class AirPlay {
        let context: JSON
        let send: (JSON) -> ()
        private var isTriggered = false
        
        init(context: JSON, send: @escaping (JSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(props: Player.Properties) {
            guard let item = props.playbackItem else { return }
            guard !isTriggered else { return }
            guard item.ad.airPlay == .active || item.content.airPlay == .active else { return }
            
            isTriggered = true
            send(telemetryJSON(withContext: context, type: "EXTERNAL_PLAYBACK_TRIGGERED"))
        }
    }
}

extension Telemetry.Metrics {
    final class Subtitles {
        let context: JSON
        let send: (JSON) -> ()
        private var triggeredSessionIds: Set<UUID> = []
        
        init(context: JSON, send: @escaping (JSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(props: Player.Properties) {
            typealias PlaybackItem = Player.Properties.PlaybackItem
            func selectedSubtitlesType(item: PlaybackItem.Available) -> String? {
                func isOptionSelected(option: PlaybackItem.Video.MediaGroup.Option?) -> Bool {
                    guard option?.selected == true else { return false }
                    guard option?.displayName != "None" else { return false }
                    return true
                }
                
                switch item.content.legible {
                case .internal(let mediaGroup):
                    guard isOptionSelected(option: mediaGroup?.selectedOption) else { return nil }
                    return "INTERNAL"
                case .external(let external):
                    guard isOptionSelected(option: external.group.selectedOption) else { return nil }
                    return "EXTERNAL"
                }
            }
            
            guard !triggeredSessionIds.contains(props.session.playback.id) else { return }
            guard let item = props.playbackItem else { return }
            guard let selectedSubtitlesType = selectedSubtitlesType(item: item) else { return }
            
            triggeredSessionIds.insert(props.session.playback.id)
            send(telemetryJSON(withContext: context,
                               type: "SUBTITLES_ENABLED",
                               value: ["subtitlesType" : selectedSubtitlesType]))
        }
    }
}

extension Telemetry.Metrics {
    struct VideoProvider {
        let context: JSON
        let send: (JSON) -> ()
        
        func process(error: Error) {
            guard let error = error as? Network.Parse.JSONError else { return }
            
            send(telemetryJSON(withContext: context,
                               type: "VIDEO_SERVICE_JSON_PARSING_ERROR",
                               value: ["responseJson": error.json,
                                       "message": error.message]))
        }
    }
}

extension Telemetry.Metrics {
    final class PictureInPicture {
        let context: JSON
        let send: (JSON) -> ()
        
        private var triggeredSessionIds: Set<UUID> = []
        
        init(context: JSON, send: @escaping (JSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(props: Player.Properties) {
            guard triggeredSessionIds.contains(props.session.playback.id) == false else { return }
            guard let item = props.playbackItem else { return }
            guard item.content.pictureInPictureMode == .active else { return }
            triggeredSessionIds.insert(props.session.playback.id)
            
            send(telemetryJSON(withContext: context, type: "PICTURE_IN_PICTURE_MODE_ENABLED"))
        }
    }
}

extension Telemetry.Metrics {
    final class AdStartTimeout {
        let context: JSON
        let send: (JSON) -> ()
        
        private var processedAds = Set<String>()
        
        init(context: JSON, send: @escaping (JSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(state: PlayerCore.State) {
            let newCoreResult = state.vrmFinalResult.successResult ?? state.vrmFinalResult.failedResult
            guard let ruleId = state.adInfoHolder?.info.ruleId ??
                newCoreResult?.item.metaInfo.ruleId else { return }
            process(isTimeoutReached: state.adKill == .adStartTimeout, for: ruleId)
        }
        func process(isTimeoutReached: Bool, for ruleId: String) {
            guard isTimeoutReached, !processedAds.contains(ruleId) else { return }
            
            processedAds.insert(ruleId)
            send(telemetryJSON(withContext: context,
                               type: "START_TIMEOUT_REACHED",
                               value: ["rid": ruleId]))
        }
    }
}

extension Telemetry.Metrics {
    final class VRMProcessing {
        
        let context: JSON
        let send: (JSON) -> ()
        
        private var processedRequests = Set<UUID>()
        
        init(context: JSON, send: @escaping (JSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(state: PlayerCore.State) {
            process(adRequest: state.vrmRequestStatus.request?.id,
                    processingTime: state.vrmProcessingTime)
        }
        
        func process(adRequest: UUID?,
                     processingTime: VRMProcessingTime) {
            guard let requestID = adRequest,
                case let .finished(startAt, finishAt) = processingTime,
                processedRequests.contains(requestID) == false else { return }
            
            processedRequests.insert(requestID)
            
            let timeInterval = Int(finishAt.timeIntervalSince(startAt) * 1000)
            send(telemetryJSON(withContext: context,
                               type: "VRM_PROCESSING_TIME",
                               value: ["time": timeInterval]))
        }
    }
}

extension Telemetry.Metrics {
    final class AdBuffering {
        
        let context: JSON
        let send: (JSON) -> ()
        
        private var processedRequests = Set<UUID>()
        
        init(context: JSON, send: @escaping (JSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(state: PlayerCore.State) {
            process(adRequest: state.vrmRequestStatus.request?.id,
                    processingTime: state.mp4AdBufferingTime)
        }
        
        func process(adRequest: UUID?,
                     processingTime: MP4AdBufferingTime) {
            guard let requestID = adRequest,
                case let .finished(startAt, finishAt) = processingTime,
                processedRequests.contains(requestID) == false else { return }
            
            processedRequests.insert(requestID)
            
            let timeInterval = Int(finishAt.timeIntervalSince(startAt) * 1000)
            send(telemetryJSON(withContext: context,
                               type: "AD_BUFFERING_TIME",
                               value: ["time": timeInterval]))
        }
        
    }
}

extension Telemetry.Metrics {
    final class VPAID {
        
        let abuseEventReporter: AbuseEventErrorReporter
        let javascriptErrorReporter: JSEvaluationErrorReporter
        let unsupportedVPAIDReporter: UnsupportedVPAIDReporter
        
        init(context: JSON, send: @escaping (JSON) -> ()) {
            abuseEventReporter = AbuseEventErrorReporter(context: context, send: send)
            javascriptErrorReporter = JSEvaluationErrorReporter(context: context, send: send)
            unsupportedVPAIDReporter = UnsupportedVPAIDReporter(context: context, send: send)
        }
        
        func process(state: PlayerCore.State) {
            let newCoreResult = state.vrmFinalResult.successResult ?? state.vrmFinalResult.failedResult
            guard let ruleId = state.adInfoHolder?.info.ruleId ??
                newCoreResult?.item.metaInfo.ruleId  else { return }
            
            abuseEventReporter.process(abusedEvents: state.vpaidErrors.abusedEvents,
                                       forRuleId: ruleId)
            javascriptErrorReporter.process(javascriptErrors: state.vpaidErrors.javaScriptEvaluationErrors,
                                            forRuleId: ruleId)
            unsupportedVPAIDReporter.process(isUnsupported: state.vpaidErrors.isAdNotSupported,
                                             forRuleId: ruleId)
        }
    }
}


extension Telemetry.Metrics.VPAID {
    final class AbuseEventErrorReporter {
        
        private struct AbuseInfo: Hashable {
            let name: String
            let ruleId: String
        }
        
        let context: JSON
        let send: (JSON) -> ()
        
        private var processedAbuseErrors = Set<AbuseInfo>()
        
        init(context: JSON, send: @escaping (JSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(abusedEvents: [VPAIDErrors.UniqueEventError], forRuleId ruleId: String) {
            abusedEvents.forEach { error in
                let candidate = AbuseInfo(name: error.eventName, ruleId: ruleId)
                guard !processedAbuseErrors.contains(candidate) else { return }
                
                processedAbuseErrors.insert(candidate)
                send(telemetryJSON(withContext: context,
                                   type: "VPAID_UNIQUE_EVENT_ABUSE",
                                   value: ["event_name": error.eventName,
                                           "rid": ruleId]))
            }
        }
    }
}

extension Telemetry.Metrics.VPAID {
    final class JSEvaluationErrorReporter {
        private struct JSErrorInfo: Hashable {
            let ruleId: String
            let errorDescription: String
        }
        
        let context: JSON
        let send: (JSON) -> ()
        
        private var processedJsErrors = Set<JSErrorInfo>()
        
        init(context: JSON, send: @escaping (JSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(javascriptErrors: [Error], forRuleId ruleId: String) {
            func prepareValue(from jsError: Error, with ruleId: String) -> JSON {
                var value: JSON = ["rid": ruleId]
                
                if let error = jsError as NSError? {
                    let userInfo = error.userInfo.reduce([:]) { (result, next) -> JSON in
                        var newResult = result
                        newResult["\(next.key)"] = "\(next.value)"
                        return newResult
                    }
                    value["error_code"] = "\(error.code)"
                    value["error_description"] = error.description
                    value["error_additional_info"] = userInfo
                } else {
                    value["error_description"] = jsError.localizedDescription
                }
                
                return value
            }
            
            javascriptErrors.forEach { jserror in
                let candidate = JSErrorInfo(ruleId: ruleId, errorDescription: jserror.localizedDescription)
                guard !processedJsErrors.contains(candidate) else { return }
                
                processedJsErrors.insert(candidate)
                send(telemetryJSON(withContext: context,
                                   type: "VPAID_JAVASCRIPT_EVALUATION_ERROR",
                                   value: prepareValue(from: jserror, with: ruleId)))
                
            }
        }
    }
}

extension Telemetry.Metrics.VPAID {
    final class UnsupportedVPAIDReporter {
        let context: JSON
        let send: (JSON) -> ()
        
        private var processedAds = Set<String>()
        
        init(context: JSON, send: @escaping (JSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(isUnsupported: Bool, forRuleId ruleId: String) {
            guard isUnsupported,
                !processedAds.contains(ruleId) else { return }
            
            processedAds.insert(ruleId)
            send(telemetryJSON(withContext: context,
                               type: "VPAID_UNSUPPORTED_VERSION_ERROR",
                               value: ["rid": ruleId]))
        }
    }
}

extension Telemetry.Metrics {
    final class OpenMeasurement {
        
        let successInitializationReporter: SuccessInitializationReporter
        let failedConfigurationReporter: FailedConfigurationReporter
        let scriptFetchingFailedReporter: ScriptFetchingFailedReporter
        
        init(context: JSON, send: @escaping (JSON) -> ()) {
            successInitializationReporter = SuccessInitializationReporter(context: context, send: send)
            failedConfigurationReporter = FailedConfigurationReporter(context: context, send: send)
            scriptFetchingFailedReporter = ScriptFetchingFailedReporter(context: context, send: send)
        }
        
        func process(state: PlayerCore.State) {
            let newCoreResult = state.vrmFinalResult.successResult ?? state.vrmFinalResult.failedResult
            guard let ruleId = state.adInfoHolder?.info.ruleId ?? newCoreResult?.item.metaInfo.ruleId else { return }
            let isMeasurementStarted: Bool = perform {
                guard case .active = state.openMeasurement else { return false }
                return true
            }
            let measurementError: Error? = perform {
                guard case .failed(let error) = state.openMeasurement else { return nil }
                return error
            }
            let fetchingError: Error? = perform {
                guard case .failed(let error) = state.serviceScript else { return nil }
                return error
            }
            successInitializationReporter.process(isMeasurementStarted: isMeasurementStarted,
                                                  forRuleId: ruleId)
            scriptFetchingFailedReporter.process(with: fetchingError)
            failedConfigurationReporter.process(with: measurementError, forRuleId: ruleId)
        }
    }
}

extension Telemetry.Metrics.OpenMeasurement {
    final class SuccessInitializationReporter {
        let context: JSON
        let send: (JSON) -> ()
        
        private var processedAds = Set<String>()
        
        init(context: JSON, send: @escaping (JSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(isMeasurementStarted: Bool, forRuleId ruleId: String) {
            guard isMeasurementStarted,
                !processedAds.contains(ruleId) else { return }
            
            processedAds.insert(ruleId)
            send(telemetryJSON(withContext: context,
                               type: "OM_SDK_INITIATED",
                               value: ["rid": ruleId]))
        }
    }
}

extension Telemetry.Metrics.OpenMeasurement {
    final class FailedConfigurationReporter {
        let context: JSON
        let send: (JSON) -> ()
        
        private var processedAds = Set<String>()
        
        init(context: JSON, send: @escaping (JSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(with error: Error?, forRuleId ruleId: String) {
            guard let error = error,
                !processedAds.contains(ruleId) else { return }
            
            processedAds.insert(ruleId)
            send(telemetryJSON(withContext: context,
                               type: "OM_SDK_ERROR",
                               value: ["message": error.localizedDescription,
                                       "rid": ruleId]))
        }
    }
}
extension Telemetry.Metrics.OpenMeasurement {
    final class ScriptFetchingFailedReporter {
        let context: JSON
        let send: (JSON) -> ()
        
        private var processed = false
        
        init(context: JSON, send: @escaping (JSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(with error: Error?) {
            guard let error = error, processed == false else { return }
            
            processed = true
            send(telemetryJSON(withContext: context,
                               type: "OM_SDK_SCRIPT_FETCHING_FAILED",
                               value: ["message": error.localizedDescription]))
        }
    }
}

func telemetryJSON(withContext context: JSON, type: String, value: JSON = [:]) -> JSON {
    return [
        "context" : context,
        "data" : [
            "type" : type,
            "value": value
        ]
    ]
}
