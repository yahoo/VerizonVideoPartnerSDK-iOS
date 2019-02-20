//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import OMSDK_Oath2
import PlayerCore

enum OpenMeasurement {
    struct Input {
        let partnerBundleName: String
        let partnerVersion: String
        let jsServiceScript: String
        let adVerifications: [PlayerCore.Ad.VASTModel.AdVerification]
    }
    struct Output {
        let adSession: OpenMeasurementAdSessionProtocol
        let adEvents: PlayerCore.OpenMeasurement.AdEvents
        let videoEvents: PlayerCore.OpenMeasurement.VideoEvents
    }
    enum Errors: Swift.Error {
        case failedToCreateOMIDPartner
        case failedToCreateVerificationScriptResource
        case failedToActivateSDK
        case scriptNotAvailable
        case failedToGetAdView
        case sdkVersionIsNotCompatible
    }
    
    static func createOpenMeasurementContext(input: Input) throws -> Output {
        if OMIDOath2SDK.shared.isActive == false {
            guard OMIDOath2SDK.isCompatible(withOMIDAPIVersion: OMIDSDKAPIVersionString) else {
                throw Errors.sdkVersionIsNotCompatible
            }
            try OMIDOath2SDK.shared.activate(withOMIDAPIVersion: OMIDSDKAPIVersionString)
            
            guard OMIDOath2SDK.shared.isActive else {
                throw Errors.failedToActivateSDK
            }
        }
        guard let partner = OMIDOath2Partner(name: input.partnerBundleName, versionString: input.partnerVersion) else {
            throw Errors.failedToCreateOMIDPartner
        }
        let verificationResources: [OMIDOath2VerificationScriptResource] = {
            return input.adVerifications.compactMap {
                guard let vendorKey = $0.vendorKey, let parameters = $0.verificationParameters else {
                    return OMIDOath2VerificationScriptResource(url: $0.javaScriptResource)
                }
                return OMIDOath2VerificationScriptResource(url: $0.javaScriptResource,
                                                       vendorKey: vendorKey,
                                                       parameters: parameters.absoluteString)
            }
        }()
        
        let context = try OMIDOath2AdSessionContext(partner: partner,
                                                    script: input.jsServiceScript,
                                                    resources: verificationResources,
                                                    customReferenceIdentifier: nil)
        
        let configuration = try OMIDOath2AdSessionConfiguration(impressionOwner: .nativeOwner,
                                                                videoEventsOwner: .nativeOwner,
                                                                isolateVerificationScripts: false)
        
        let adSession = try OMIDOath2AdSession(configuration: configuration, adSessionContext: context)
        
        let omidAdEvents = try OMIDOath2AdEvents(adSession: adSession)
        let omidVideoEvents = try OMIDOath2VideoEvents(adSession: adSession)
        
        let adEvents = PlayerCore.OpenMeasurement.AdEvents(
            impressionOccurred: { try? omidAdEvents.impressionOccurred() }
        )
        let videoEvents = PlayerCore.OpenMeasurement.VideoEvents(
            loaded: { (position, autoplay) in
                let position: OMIDPosition = {
                    switch position {
                    case .preroll: return .preroll
                    case .midroll: return .midroll
                    }
                }()
                let properties = OMIDOath2VASTProperties(autoPlay: autoplay, position: position)
                omidVideoEvents.loaded(with: properties)},
            bufferFinish: omidVideoEvents.bufferFinish,
            bufferStart: omidVideoEvents.bufferStart,
            start: { (duration, volume) in
                omidVideoEvents.start(withDuration: duration, videoPlayerVolume: volume)},
            firstQuartile: omidVideoEvents.firstQuartile,
            midpoint: omidVideoEvents.midpoint,
            thirdQuartile: omidVideoEvents.thirdQuartile,
            complete: omidVideoEvents.complete,
            resume: omidVideoEvents.resume,
            pause: omidVideoEvents.pause,
            click: { omidVideoEvents.adUserInteraction(withType: .click) },
            volumeChange: omidVideoEvents.volumeChange,
            skip: omidVideoEvents.skipped)
        
        return Output(adSession: adSession, adEvents: adEvents, videoEvents: videoEvents)
    }
}
protocol OpenMeasurementAdSessionProtocol {
    var mainAdView: UIView? { get set }
    func start()
    func finish()
}
extension OMIDOath2AdSession: OpenMeasurementAdSessionProtocol {}
