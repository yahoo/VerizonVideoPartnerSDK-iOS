//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import OMSDK_Verizonmedia
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
    enum Errors: CustomNSError {
        case failedToCreateOMIDPartner
        case failedToCreateVerificationScriptResource
        case failedToActivateSDK
        case scriptNotAvailable
        case failedToGetAdView
        case sdkVersionIsNotCompatible
        
        var errorUserInfo: [String : Any] {
            return [NSLocalizedDescriptionKey : "\(self)"]
        }
    }
    
    static func createOpenMeasurementContext(input: Input) throws -> Output {
        if OMIDVerizonmediaSDK.shared.isActive == false {
            guard OMIDVerizonmediaSDK.isCompatible(withOMIDAPIVersion: OMIDSDKAPIVersionString) else {
                throw Errors.sdkVersionIsNotCompatible
            }
            try OMIDVerizonmediaSDK.shared.activate(withOMIDAPIVersion: OMIDSDKAPIVersionString)
            
            guard OMIDVerizonmediaSDK.shared.isActive else {
                throw Errors.failedToActivateSDK
            }
        }
        guard let partner = OMIDVerizonmediaPartner(name: input.partnerBundleName, versionString: input.partnerVersion) else {
            throw Errors.failedToCreateOMIDPartner
        }
        let verificationResources: [OMIDVerizonmediaVerificationScriptResource] = {
            return input.adVerifications.compactMap {
                guard let vendorKey = $0.vendorKey, let parameters = $0.verificationParameters else {
                    return OMIDVerizonmediaVerificationScriptResource(url: $0.javaScriptResource)
                }
                return OMIDVerizonmediaVerificationScriptResource(url: $0.javaScriptResource,
                                                                  vendorKey: vendorKey,
                                                                  parameters: parameters.absoluteString)
            }
        }()
        
        let context = try OMIDVerizonmediaAdSessionContext(partner: partner,
                                                           script: input.jsServiceScript,
                                                           resources: verificationResources,
                                                           customReferenceIdentifier: nil)
        
        let configuration = try OMIDVerizonmediaAdSessionConfiguration(impressionOwner: .nativeOwner,
                                                                       videoEventsOwner: .nativeOwner,
                                                                       isolateVerificationScripts: false)
        
        let adSession = try OMIDVerizonmediaAdSession(configuration: configuration, adSessionContext: context)
        
        let omidAdEvents = try OMIDVerizonmediaAdEvents(adSession: adSession)
        let omidVideoEvents = try OMIDVerizonmediaVideoEvents(adSession: adSession)
        
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
                let properties = OMIDVerizonmediaVASTProperties(autoPlay: autoplay, position: position)
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
extension OMIDVerizonmediaAdSession: OpenMeasurementAdSessionProtocol {}
