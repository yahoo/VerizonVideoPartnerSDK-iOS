//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public extension VRMCore {
    
    /// Currently we support only InLine ads.
    public enum VASTModel: Hashable {
        
        public struct WrapperModel: Hashable {
            public let tagURL: URL
            public let adVerifications: [Ad.VASTModel.AdVerification]
            public let pixels: AdPixels
            
            public init(tagURL: URL,
                        adVerifications: [Ad.VASTModel.AdVerification],
                        pixels: AdPixels) {
                self.tagURL = tagURL
                self.adVerifications = adVerifications
                self.pixels = pixels
            }
        }
        
        case wrapper(WrapperModel)
        case inline(Ad.VASTModel)
    }
}

public extension VRMCore.VASTModel.WrapperModel {
    func merge(with pixels: AdPixels, and verifications: [Ad.VASTModel.AdVerification]) -> VRMCore.VASTModel.WrapperModel {
        return VRMCore.VASTModel.WrapperModel(tagURL: tagURL,
                                              adVerifications: self.adVerifications + verifications,
                                              pixels: self.pixels.merge(with: pixels))
    }
}

public extension Ad.VASTModel {
    public func merge(with pixels: AdPixels, and verifications: [Ad.VASTModel.AdVerification]) -> Ad.VASTModel {
        return PlayerCore.Ad.VASTModel(
            adVerifications: self.adVerifications + verifications,
            mp4MediaFiles: mp4MediaFiles,
            vpaidMediaFiles: vpaidMediaFiles,
            skipOffset: skipOffset,
            clickthrough: clickthrough,
            adParameters: adParameters,
            adProgress: self.adProgress + adProgress,
            pixels: self.pixels.merge(with: pixels),
            id: id)
    }
}

public extension AdPixels {
    public func merge(with pixels: AdPixels) -> AdPixels {
        return AdPixels(
            impression: impression + pixels.impression,
            error: error + pixels.error,
            clickTracking: clickTracking + pixels.clickTracking,
            creativeView: creativeView + pixels.creativeView,
            start: start + pixels.start,
            firstQuartile: firstQuartile + pixels.firstQuartile,
            midpoint: midpoint + pixels.midpoint,
            thirdQuartile: thirdQuartile + pixels.thirdQuartile,
            complete: complete + pixels.complete,
            pause: pause + pixels.pause,
            resume: resume + pixels.resume,
            skip: skip + pixels.skip,
            mute: mute + pixels.mute,
            unmute: unmute + pixels.unmute,
            acceptInvitation: acceptInvitation + pixels.acceptInvitation,
            acceptInvitationLinear: acceptInvitationLinear + pixels.acceptInvitationLinear,
            close: close + pixels.close,
            closeLinear: closeLinear + pixels.closeLinear,
            collapse: collapse + pixels.collapse
        )
    }
}
