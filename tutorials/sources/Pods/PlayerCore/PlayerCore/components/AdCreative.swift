//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public enum AdCreative {
    case mp4(MP4), vpaid(VPAID), none
    
    public struct MP4 {
        public let url: URL
        public let clickthrough: URL?
        public let pixels: AdPixels
        public let id: String?
        public let scalable: Bool
        public let maintainAspectRatio: Bool
        
        public init(url: URL,
                    clickthrough: URL?,
                    pixels: AdPixels,
                    id: String?,
                    scalable: Bool,
                    maintainAspectRatio: Bool) {
            self.url = url
            self.clickthrough = clickthrough
            self.pixels = pixels
            self.id = id
            self.scalable = scalable
            self.maintainAspectRatio = maintainAspectRatio
        }
    }
    public struct VPAID {
        public let url: URL
        public let adParameters: String?
        public let clickthrough: URL?
        public let pixels: AdPixels
        public let id: String?
        
        public init(url: URL,
                    adParameters: String?,
                    clickthrough: URL?,
                    pixels: AdPixels,
                    id: String?) {
            self.url = url
            self.adParameters = adParameters
            self.clickthrough = clickthrough
            self.pixels = pixels
            self.id = id
        }
    }
}
