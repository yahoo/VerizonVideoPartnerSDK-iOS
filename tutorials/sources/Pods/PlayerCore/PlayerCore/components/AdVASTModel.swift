//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
extension Ad {
    public struct VASTModel: Hashable {
        public let adVerifications: [AdVerification]
        public let mp4MediaFiles: [MP4MediaFile]
        public let vpaidMediaFiles: [VPAIDMediaFile]
        public let skipOffset: VASTOffset?
        public let clickthrough: URL?
        public let adParameters: String?
        public let adProgress: [AdProgress]
        public let pixels: AdPixels
        public let id: String?
        
        public struct MP4MediaFile: Hashable {
            public let url: URL
            public let width: Int
            public let height: Int
            public let scalable: Bool
            public let maintainAspectRatio: Bool
            
            public init(url: URL,
                        width: Int,
                        height: Int,
                        scalable: Bool,
                        maintainAspectRatio: Bool) {
                self.url = url
                self.width = width
                self.height = height
                self.scalable = scalable
                self.maintainAspectRatio = maintainAspectRatio
            }
        }
        public struct VPAIDMediaFile: Hashable {
            public let url: URL
            public let scalable: Bool
            public let maintainAspectRatio: Bool
            
            public init(url: URL,
                        scalable: Bool,
                        maintainAspectRatio: Bool) {
                self.url = url
                self.scalable = scalable
                self.maintainAspectRatio = maintainAspectRatio
            }
        }
        
        public enum VASTOffset: Hashable {
            case time(Int)
            case percentage(Int)
        }
        
        public struct AdProgress: Hashable {
            public let url: URL
            public let offset: Ad.VASTModel.VASTOffset
            
            public init(url: URL, offset: Ad.VASTModel.VASTOffset) {
                self.url = url
                self.offset = offset
            }
        }
        
        public struct AdVerification: Hashable {
            public let vendorKey: String?
            public let javaScriptResource: URL
            public let verificationParameters: URL?
            public let verificationNotExecuted: URL?
            
            public init(vendorKey: String?,
                        javaScriptResource: URL,
                        verificationParameters: URL?,
                        verificationNotExecuted: URL?) {
                self.vendorKey = vendorKey
                self.javaScriptResource = javaScriptResource
                self.verificationParameters = verificationParameters
                self.verificationNotExecuted = verificationNotExecuted
            }
        }
        public init(adVerifications: [AdVerification],
                    mp4MediaFiles: [MP4MediaFile],
                    vpaidMediaFiles: [VPAIDMediaFile],
                    skipOffset: VASTOffset?,
                    clickthrough: URL?,
                    adParameters: String?,
                    adProgress: [AdProgress],
                    pixels: AdPixels,
                    id: String?) {
            self.adVerifications = adVerifications
            self.mp4MediaFiles = mp4MediaFiles
            self.vpaidMediaFiles = vpaidMediaFiles
            self.skipOffset = skipOffset
            self.clickthrough = clickthrough
            self.adParameters = adParameters
            self.adProgress = adProgress
            self.pixels = pixels
            self.id = id
        }
    }
}
