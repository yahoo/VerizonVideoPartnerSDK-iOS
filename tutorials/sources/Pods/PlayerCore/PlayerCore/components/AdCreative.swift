//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public enum AdCreative: Hashable {
    case mp4([MP4]), vpaid([VPAID]), none
    
    public struct MP4: Hashable {
        public let internalID: UUID
        public let url: URL
        public let clickthrough: URL?
        public let pixels: AdPixels
        public let id: String?
        public let width: Int
        public let height: Int
        public let scalable: Bool
        public let maintainAspectRatio: Bool
        
        public init( internalID: UUID = UUID(),
                     url: URL,
                     clickthrough: URL?,
                     pixels: AdPixels,
                     id: String?,
                     width: Int,
                     height: Int,
                     scalable: Bool,
                     maintainAspectRatio: Bool) {
            self.internalID = internalID
            self.url = url
            self.clickthrough = clickthrough
            self.pixels = pixels
            self.id = id
            self.width = width
            self.height = height
            self.scalable = scalable
            self.maintainAspectRatio = maintainAspectRatio
        }
    }
    public struct VPAID: Hashable {
        public let internalID: UUID
        public let url: URL
        public let adParameters: String?
        public let clickthrough: URL?
        public let pixels: AdPixels
        public let id: String?
        
        public init(internalID: UUID = UUID(),
                    url: URL,
                    adParameters: String?,
                    clickthrough: URL?,
                    pixels: AdPixels,
                    id: String?) {
            self.internalID = internalID
            self.url = url
            self.adParameters = adParameters
            self.clickthrough = clickthrough
            self.pixels = pixels
            self.id = id
        }
    }
}

func reduce(state: AdCreative, action: Action) -> AdCreative {
    switch action {
    case let action as VRMCore.SelectFinalResult:
        let mp4AdCreatives: [AdCreative.MP4] = action.inlineVAST.mp4MediaFiles.compactMap {
            return .init(
                url: $0.url,
                clickthrough: action.inlineVAST.clickthrough,
                pixels: action.inlineVAST.pixels,
                id: action.inlineVAST.id,
                width: $0.width,
                height: $0.height,
                scalable: $0.scalable,
                maintainAspectRatio: $0.maintainAspectRatio)
        }
        guard mp4AdCreatives.isEmpty else {
            return .mp4(mp4AdCreatives)
        }
        let vpaidAdCreatives: [AdCreative.VPAID] = action.inlineVAST.vpaidMediaFiles.compactMap {
            return .init(
                url: $0.url,
                adParameters: action.inlineVAST.adParameters,
                clickthrough: action.inlineVAST.clickthrough,
                pixels: action.inlineVAST.pixels,
                id: action.inlineVAST.id)
        }
        guard vpaidAdCreatives.isEmpty else {
            return .vpaid(vpaidAdCreatives)
        }
        return .none
    case let action as ShowAd:
        return action.creative
    case is VRMCore.AdRequest:
        return .none
    default: return state
    }
}

