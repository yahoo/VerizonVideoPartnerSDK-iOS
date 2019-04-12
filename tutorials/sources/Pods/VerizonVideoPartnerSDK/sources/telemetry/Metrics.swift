//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import PlayerCore
import CoreMedia
extension Telemetry {
    
    struct TelemetryJSON {
        let context: JSON
        let data: JSøN
    }

    struct Metrics {
        let airPlay: AirPlay
        let subtitles: Subtitles
        let videoProvider: VideoProvider
        let pictureInPicture: PictureInPicture
        let adStartTimeout: AdStartTimeout
        let vpaid: VPAID
        let openMeasurement: OpenMeasurement
        let buffering: Buffering
        
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
            buffering = Buffering(context: context, send: send)
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
            buffering.process(state: state)
        }
        
        func process(videoProviderError error: Error) {
            videoProvider.process(error: error)
        }
    }
}

extension Telemetry.Metrics {
    final class AirPlay {
        let context: JSON
        let send: (Telemetry.TelemetryJSON) -> ()
        private var isTriggered = false
        
        init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(props: Player.Properties) {
            guard let item = props.playbackItem else { return }
            guard !isTriggered else { return }
            guard item.ad.airPlay == .active || item.content.airPlay == .active else { return }
            
            isTriggered = true
            send(telemetryJSøN(withContext: context, type: "EXTERNAL_PLAYBACK_TRIGGERED"))
        }
    }
}

extension Telemetry.Metrics {
    final class Subtitles {
        let context: JSON
        let send: (Telemetry.TelemetryJSON) -> ()
        private var triggeredSessionIds: Set<UUID> = []
        
        init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
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
            send(telemetryJSøN(withContext: context,
                               type: "SUBTITLES_ENABLED",
                               value: ["subtitlesType" : selectedSubtitlesType |> json] |> json))
        }
    }
}

extension Telemetry.Metrics {
    struct VideoProvider {
        let context: JSON
        let send: (Telemetry.TelemetryJSON) -> ()
        
        func process(error: Error) {
            guard let error = error as? Network.Parse.JSONError else { return }
            
            send(telemetryJSøN(withContext: context,
                               type: "VIDEO_SERVICE_JSON_PARSING_ERROR",
                               value: ["responseJSON": error.json |> json,
                                       "message": error.message |> json] |> json))
        }
    }
}

extension Telemetry.Metrics {
    final class PictureInPicture {
        let context: JSON
        let send: (Telemetry.TelemetryJSON) -> ()
        
        private var triggeredSessionIds: Set<UUID> = []
        
        init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(props: Player.Properties) {
            guard triggeredSessionIds.contains(props.session.playback.id) == false else { return }
            guard let item = props.playbackItem else { return }
            guard item.content.pictureInPictureMode == .active else { return }
            triggeredSessionIds.insert(props.session.playback.id)
            
            send(telemetryJSøN(withContext: context, type: "PICTURE_IN_PICTURE_MODE_ENABLED"))
        }
    }
}

extension Telemetry.Metrics {
    final class AdStartTimeout {
        let context: JSON
        let send: (Telemetry.TelemetryJSON) -> ()
        
        private var processedAds = Set<String>()
        
        init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(state: PlayerCore.State) {
            process(isTimeoutReached: state.adKill == .adStartTimeout,
                    for: state.vrmFinalResult.failedResult?.item.metaInfo.ruleId)
        }
        func process(isTimeoutReached: Bool, for ruleId: String?) {
            guard let ruleId = ruleId else { return }
            guard isTimeoutReached, !processedAds.contains(ruleId) else { return }
            
            processedAds.insert(ruleId)
            send(telemetryJSøN(withContext: context,
                               type: "START_TIMEOUT_REACHED",
                               value: ["rid": ruleId |> json] |> json))
        }
    }
}

extension Telemetry.Metrics {
    struct Buffering {
        
        final class Reporter {
            
            let context: JSON
            let send: (Telemetry.TelemetryJSON) -> ()
            
            private var uniqueKeys = Set<UUID>()
            
            init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
                self.context = context
                self.send = send
            }
            func process(uniqueKey: UUID?,
                         processingTime: BufferingStatus,
                         telemetryType: String) {
                guard let uniqueKey = uniqueKey,
                    case let .finished(startAt, finishAt) = processingTime,
                    uniqueKeys.contains(uniqueKey) == false else { return }
                
                uniqueKeys.insert(uniqueKey)
                
                let timeInterval = Int(finishAt.timeIntervalSince(startAt) * 1000)
                send(telemetryJSøN(withContext: context,
                                   type: telemetryType,
                                   value: ["time": timeInterval |> json] |> json))
            }
        }
        
        let vrm: VRM
        let mp4Ad: MP4Ad
        let content: Content
        
        init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
            mp4Ad = MP4Ad(context: context, send: send)
            vrm = VRM(context: context, send: send)
            content = Content(context: context, send: send)
        }
        
        func process(state: PlayerCore.State) {
            mp4Ad.process(requestId: state.vrmRequestStatus.request?.id,
                          processingStatus: state.mp4AdBufferingTime.status)
            
            vrm.process(requestId: state.vrmRequestStatus.request?.id,
                        processingStatus: state.vrmProcessingTime.status)
            
            content.process(playbackSession: state.playbackSession.id,
                            processingStatus: state.contentBufferingTime.status)
        }
    }
}

extension Telemetry.Metrics.Buffering {
    struct MP4Ad {
        let mp4Ad: Reporter
        
        init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
            mp4Ad = Reporter(context: context, send: send)
        }
        
        func process(requestId: UUID?, processingStatus: BufferingStatus) {
            mp4Ad.process(uniqueKey: requestId,
                          processingTime: processingStatus,
                          telemetryType: "AD_BUFFERING_TIME")
        }
    }
}

extension Telemetry.Metrics.Buffering {
    struct VRM {
        let vrm: Reporter
        
        init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
            vrm = Reporter(context: context, send: send)
        }
        
        func process(requestId: UUID?, processingStatus: BufferingStatus) {
            vrm.process(uniqueKey: requestId,
                        processingTime: processingStatus,
                          telemetryType: "VRM_PROCESSING_TIME")
        }
    }
}

extension Telemetry.Metrics.Buffering {
    struct Content {
        let content: Reporter
        
        init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
            content = Reporter(context: context, send: send)
        }
        
        func process(playbackSession: UUID?,
                     processingStatus: BufferingStatus) {
            content.process(uniqueKey: playbackSession,
                        processingTime: processingStatus,
                        telemetryType: "VIDEO_BUFFERING_TIME")
        }
    }
}

extension Telemetry.Metrics {
    final class VPAID {
        
        let abuseEventReporter: AbuseEventErrorReporter
        let javascriptErrorReporter: JSEvaluationErrorReporter
        let unsupportedVPAIDReporter: UnsupportedVPAIDReporter
        
        init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
            abuseEventReporter = AbuseEventErrorReporter(context: context, send: send)
            javascriptErrorReporter = JSEvaluationErrorReporter(context: context, send: send)
            unsupportedVPAIDReporter = UnsupportedVPAIDReporter(context: context, send: send)
        }
        
        func process(state: PlayerCore.State) {
            abuseEventReporter.process(abusedEvents: state.vpaidErrors.abusedEvents,
                                       forRuleId: state.vrmFinalResult.successResult?.item.metaInfo.ruleId)
            javascriptErrorReporter.process(javascriptErrors: state.vpaidErrors.javaScriptEvaluationErrors,
                                            forRuleId: state.vrmFinalResult.failedResult?.item.metaInfo.ruleId)
            unsupportedVPAIDReporter.process(isUnsupported: state.vpaidErrors.isAdNotSupported,
                                             forRuleId: state.vrmFinalResult.failedResult?.item.metaInfo.ruleId)
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
        let send: (Telemetry.TelemetryJSON) -> ()
        
        private var processedAbuseErrors = Set<AbuseInfo>()
        
        init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(abusedEvents: [VPAIDErrors.UniqueEventError], forRuleId ruleId: String?) {
            guard let ruleId = ruleId else { return }
            abusedEvents.forEach { error in
                let candidate = AbuseInfo(name: error.eventName, ruleId: ruleId)
                guard !processedAbuseErrors.contains(candidate) else { return }
                
                processedAbuseErrors.insert(candidate)
                send(telemetryJSøN(withContext: context,
                                   type: "VPAID_UNIQUE_EVENT_ABUSE",
                                   value: ["event_name": error.eventName |> json,
                                           "rid": ruleId |> json] |> json))
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
        let send: (Telemetry.TelemetryJSON) -> ()
        
        private var processedJsErrors = Set<JSErrorInfo>()
        
        init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(javascriptErrors: [Error], forRuleId ruleId: String?) {
            guard let ruleId = ruleId else { return }
            func prepareValue(from jsError: Error, with ruleId: String) -> JSøN {
                let value: JSøN = {
                    if let error = jsError as NSError? {
                        let ruleIdJson = ruleId |> json
                        let errorCodeJson = "\(error.code)" |> json
                        let errorDescriptionJson = error.description |> json
                        let errorUserInfoJson = error.userInfo.description |> json
                        return [
                            "rid" : ruleIdJson,
                            "error_code" : errorCodeJson,
                            "error_description" : errorDescriptionJson,
                            "error_additional_info": errorUserInfoJson
                            ] |> json
                    } else {
                        return [
                            "rid" : ruleId |> json,
                            "error_description" : jsError.localizedDescription |> json
                            ] |> json
                    }
                }()
                return value
            }
            
            javascriptErrors.forEach { jserror in
                let candidate = JSErrorInfo(ruleId: ruleId, errorDescription: jserror.localizedDescription)
                guard !processedJsErrors.contains(candidate) else { return }
                
                processedJsErrors.insert(candidate)
                send(telemetryJSøN(withContext: context,
                                   type: "VPAID_JAVASCRIPT_EVALUATION_ERROR",
                                   value: prepareValue(from: jserror, with: ruleId)))
                
            }
        }
    }
}

extension Telemetry.Metrics.VPAID {
    final class UnsupportedVPAIDReporter {
        let context: JSON
        let send: (Telemetry.TelemetryJSON) -> ()
        
        private var processedAds = Set<String>()
        
        init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(isUnsupported: Bool, forRuleId ruleId: String?) {
            guard isUnsupported,
                let ruleId = ruleId,
                !processedAds.contains(ruleId) else { return }
            
            processedAds.insert(ruleId)
            send(telemetryJSøN(withContext: context,
                               type: "VPAID_UNSUPPORTED_VERSION_ERROR",
                               value: ["rid": ruleId |> json] |> json))
        }
    }
}

extension Telemetry.Metrics {
    final class OpenMeasurement {
        
        let successInitializationReporter: SuccessInitializationReporter
        let failedConfigurationReporter: FailedConfigurationReporter
        let scriptFetchingFailedReporter: ScriptFetchingFailedReporter
        
        init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
            successInitializationReporter = SuccessInitializationReporter(context: context, send: send)
            failedConfigurationReporter = FailedConfigurationReporter(context: context, send: send)
            scriptFetchingFailedReporter = ScriptFetchingFailedReporter(context: context, send: send)
        }
        
        func process(state: PlayerCore.State) {
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
                                                  forRuleId: state.vrmFinalResult.successResult?.item.metaInfo.ruleId)
            scriptFetchingFailedReporter.process(with: fetchingError)
            failedConfigurationReporter.process(with: measurementError, forRuleId: state.vrmFinalResult.failedResult?.item.metaInfo.ruleId)
        }
    }
}

extension Telemetry.Metrics.OpenMeasurement {
    final class SuccessInitializationReporter {
        let context: JSON
        let send: (Telemetry.TelemetryJSON) -> ()
        
        private var processedAds = Set<String>()
        
        init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(isMeasurementStarted: Bool, forRuleId ruleId: String?) {
            guard isMeasurementStarted,
                let ruleId = ruleId,
                !processedAds.contains(ruleId) else { return }
            
            processedAds.insert(ruleId)
            send(telemetryJSøN(withContext: context,
                               type: "OM_SDK_INITIATED",
                               value: ["rid": ruleId |> json] |> json))
        }
    }
}

extension Telemetry.Metrics.OpenMeasurement {
    final class FailedConfigurationReporter {
        let context: JSON
        let send: (Telemetry.TelemetryJSON) -> ()
        
        private var processedAds = Set<String>()
        
        init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(with error: Error?, forRuleId ruleId: String?) {
            guard let ruleId = ruleId else { return }
            guard let error = error,
                !processedAds.contains(ruleId) else { return }
            
            processedAds.insert(ruleId)
            send(telemetryJSøN(withContext: context,
                               type: "OM_SDK_ERROR",
                               value: ["message": error.localizedDescription |> json,
                                       "rid": ruleId |> json] |> json))
        }
    }
}
extension Telemetry.Metrics.OpenMeasurement {
    final class ScriptFetchingFailedReporter {
        let context: JSON
        let send: (Telemetry.TelemetryJSON) -> ()
        
        private var processed = false
        
        init(context: JSON, send: @escaping (Telemetry.TelemetryJSON) -> ()) {
            self.context = context
            self.send = send
        }
        
        func process(with error: Error?) {
            guard let error = error, processed == false else { return }
            
            processed = true
            send(telemetryJSøN(withContext: context,
                               type: "OM_SDK_SCRIPT_FETCHING_FAILED",
                               value: ["message": error.localizedDescription |> json] |> json))
        }
    }
}

func telemetryJSøN(withContext context: JSON, type: String, value: JSøN = .null) -> Telemetry.TelemetryJSON {
    let data: JSøN = [
        "data" : [
            "type" : type |> json,
            "value": value
            ] |> json
        ] |> json
    return Telemetry.TelemetryJSON(context: context, data: data)
}
