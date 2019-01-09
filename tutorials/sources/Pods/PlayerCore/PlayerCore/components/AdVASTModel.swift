//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
extension Ad {
    public struct VASTModel: Equatable {
        public let adVerifications: [AdVerification]
        public let mediaFiles: [MediaFile]
        public let clickthrough: URL?
        public let adParameters: String?
        public let pixels: AdPixels
        public let id: String?
        
        public struct MediaFile: Equatable {
            public let url: URL
            public let type: VideoType
            public let width: Int
            public let height: Int
            public let scalable: Bool
            public let maintainAspectRatio: Bool
            
            public init(url: URL,
                        type: VideoType,
                        width: Int,
                        height: Int,
                        scalable: Bool,
                        maintainAspectRatio: Bool) {
                self.url = url
                self.type = type
                self.width = width
                self.height = height
                self.scalable = scalable
                self.maintainAspectRatio = maintainAspectRatio
            }
            public enum VideoType { case mp4, vpaid }
        }
        public struct AdVerification: Equatable {
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
                    mediaFiles: [MediaFile],
                    clickthrough: URL?,
                    adParameters: String?,
                    pixels: AdPixels,
                    id: String?) {
            self.adVerifications = adVerifications
            self.mediaFiles = mediaFiles
            self.clickthrough = clickthrough
            self.adParameters = adParameters
            self.pixels = pixels
            self.id = id
        }
    }
}
