//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

/// This struct is the description of player.
/// It will include what to play and in which order.
public struct Model {
    public struct VideoModel {
        public let url: URL
        public let isAirPlayEnabled: Bool
        public let isPictureInPictureModeSupported: Bool
        public let renderer: Descriptor
        
        public init(url: URL,
                    isAirPlayEnabled: Bool = false,
                    isPictureInPictureModeSupported: Bool = false,
                    renderer: Descriptor) {
            self.url = url
            self.isAirPlayEnabled = isAirPlayEnabled
            self.isPictureInPictureModeSupported = isPictureInPictureModeSupported
            self.renderer = renderer
        }
    }
    
    /// Initialises model with video model.
    ///
    /// - parameter model: Video model.
    /// - parameter autoplay: Optional. By default true.
    /// If true - first video will begin playing immediately
    /// after buffering, else - first video will be in paused state.
    /// - parameter controlsAnimationSupported: By default false
    /// - parameter prefetchingOffset: The offset for ad prefetching. By default 0
    /// - returns: Model struct.
    public init(video: VideoModel,
                autoplay: Bool = true,
                controlsAnimationSupported: Bool = false,
                isVPAIDAllowed: Bool = false,
                isOpenMeasurementAllowed: Bool = false,
                isFailoverEnabled: Bool = false,
                adSettings: AdSettings = .default,
                vpaidSettings: VPAIDSettings,
                omSettings: OMSettings) {
        self.init(videos: [video],
                  autoplay: autoplay,
                  controlsAnimationSupported: controlsAnimationSupported,
                  isVPAIDAllowed: isVPAIDAllowed,
                  isOpenMeasurementAllowed: isOpenMeasurementAllowed,
                  isFailoverEnabled: isFailoverEnabled,
                  adSettings: adSettings,
                  vpaidSettings: vpaidSettings,
                  omSettings: omSettings)
    }
    
    /// Initialises model with array of video models.
    ///
    /// - parameter models: Array of video models.
    /// - parameter autoplay: Optional. By default true.
    /// If true - first video will begin playing immediately
    /// after buffering, else - first video will be in paused state.
    /// - parameter controlsAnimationSupported: By default false
    /// - parameter prefetchingOffset: The offset for ad prefetching. By default 0
    public init(videos: [VideoModel],
                autoplay: Bool = true,
                controlsAnimationSupported: Bool = false,
                isVPAIDAllowed: Bool = false,
                isOpenMeasurementAllowed: Bool = false,
                isFailoverEnabled: Bool = false,
                adSettings: AdSettings = .default,
                vpaidSettings: VPAIDSettings,
                omSettings: OMSettings) {
        self.init(
            playlist: videos.map { Video.available(.init(url: $0.url,
                                                         renderer: $0.renderer,
                                                         ad: .noAds(),
                                                         isAirPlayEnabled: $0.isAirPlayEnabled,
                                                         isPictureInPictureModeSupported: $0.isPictureInPictureModeSupported,
                                                         brandedContent: nil)) },
            autoplay: autoplay,
            controlsAnimationSupported: controlsAnimationSupported,
            isVPAIDAllowed: isVPAIDAllowed,
            isOpenMeasurementAllowed: isOpenMeasurementAllowed,
            isFailoverEnabled: isFailoverEnabled,
            adSettings: adSettings,
            vpaidSettings: vpaidSettings,
            omSettings: omSettings)
    }
    
    public init(playlist: [Video],
                autoplay: Bool = true,
                controlsAnimationSupported: Bool = false,
                isVPAIDAllowed: Bool = false,
                isOpenMeasurementAllowed: Bool = false,
                isFailoverEnabled: Bool = false,
                adSettings: AdSettings = .default,
                vpaidSettings: VPAIDSettings,
                omSettings: OMSettings) {
        self.playlist = playlist
        self.isAutoplayEnabled = autoplay
        self.isControlsAnimationSupported = controlsAnimationSupported
        self.isVPAIDAllowed = isVPAIDAllowed
        self.isOpenMeasurementAllowed = isOpenMeasurementAllowed
        self.isFailoverEnabled = isFailoverEnabled
        self.adSettings = adSettings
        self.vpaidSettings = vpaidSettings
        self.omSettings = omSettings
    }
    
    /// Autoplay setting.
    /// If true - first video will begin playing immediately
    /// after buffering, else - first video will be in paused state.
    public let isAutoplayEnabled: Bool
    /// Represents array of video models (playlist)
    public let playlist: [Video]
    /// Animations setting
    /// If true - player controls will appear/disappear animated with
    /// duration specified in controls, else - they will do it immediately
    public let isControlsAnimationSupported: Bool
    /// The adSettings value, that includes prefetching, soft and hard timeouts.
    public let adSettings: AdSettings
    /// vpaidSettings object has necessary values to show vpaid ad
    /// - parameter document: url on the document that is used inside of a webview
    public let vpaidSettings: VPAIDSettings
    /// omSettings object has necessary values to perform open measurement
    /// - parameter serviceScriptURL: url on the script that is used to perform measurement
    public let omSettings: OMSettings
    /// The value that represents VPAID possibility
    public let isVPAIDAllowed: Bool
    /// The value that represents Open Measurement possibility
    public let isOpenMeasurementAllowed: Bool
    
    public let isFailoverEnabled: Bool
    
    public struct AdSettings {
        public static let `default` = AdSettings(prefetchingOffset: 0,
                                                 softTimeout: 0.5,
                                                 hardTimeout: 2.5,
                                                 startTimeout: 3.5,
                                                 maxSearchTime: 9.0,
                                                 maxDuration: 90,
                                                 maxVASTWrapperRedirectCount: 3)
        
        public let prefetchingOffset: Int
        public let softTimeout: Double
        public let hardTimeout: Double
        public let startTimeout: Double
        public let maxSearchTime: Double
        public let maxDuration: Int
        public let maxVASTWrapperRedirectCount: Int
        
        public init(prefetchingOffset: Int,
                    softTimeout: Double,
                    hardTimeout: Double,
                    startTimeout: Double,
                    maxSearchTime: Double,
                    maxDuration: Int,
                    maxVASTWrapperRedirectCount: Int) {
            self.prefetchingOffset = prefetchingOffset
            self.softTimeout = softTimeout
            self.hardTimeout = hardTimeout
            self.maxSearchTime = maxSearchTime
            self.startTimeout = startTimeout
            self.maxDuration = maxDuration
            self.maxVASTWrapperRedirectCount = maxVASTWrapperRedirectCount
        }
    }
    public struct VPAIDSettings {
        public let document: URL
        
        public init(document: URL) {
            self.document = document
        }
    }
    
    public struct OMSettings {
        public let serviceScriptURL: URL
        
        public init(serviceScriptURL: URL) {
            self.serviceScriptURL = serviceScriptURL
        }
    }
    
    public enum Video {
        public typealias Reason = String
        case available(Item)
        case unavailable(Reason)
        
        public var available: Item? {
            guard case .available(let item) = self else { return nil }
            return item
        }
    }
}

extension Model.Video {
    /// Represents content video item.
    public struct Item {
        /// Concrete video renderer.
        public let renderer: Descriptor
        
        /// Content video url.
        public let url: URL
        
        /// Video title string.
        public let title: String
        
        public let ad: AdModel
        
        public let thumbnail: Thumbnail?
        
        public let isAirPlayEnabled: Bool
        
        public let brandedContent: BrandedContent?
        /// Native iPad-only Picture-In-Picture mode
        public let isPictureInPictureModeSupported: Bool
        
        public init(url: URL,
                    renderer: Descriptor,
                    ad: AdModel,
                    isAirPlayEnabled: Bool,
                    isPictureInPictureModeSupported: Bool,
                    brandedContent: BrandedContent?,
                    title: String = "",
                    thumbnail: Thumbnail? = nil) {
            self.url = url
            self.title = title
            self.renderer = renderer
            self.ad = ad
            self.thumbnail = thumbnail
            self.isAirPlayEnabled = isAirPlayEnabled
            self.isPictureInPictureModeSupported = isPictureInPictureModeSupported
            self.brandedContent = brandedContent
        }
    }
}

extension Model.Video.Item {
    public struct AdModel {
        public let preroll: [Preroll]
        public let midroll: [Midroll]
        
        public struct Preroll {
            public let url: URL
            
            public init(url: URL) {
                self.url = url
            }
        }
        
        public struct Midroll {
            public let cuePoint: Int
            public let url: URL
            
            public init(cuePoint: Int, url: URL) {
                self.cuePoint = cuePoint
                self.url = url
            }
        }
        
        static func noAds() -> AdModel {
            return AdModel(preroll: [], midroll: [])
        }
        
        public init(preroll: [Preroll], midroll: [Midroll]) {
            self.preroll = preroll
            self.midroll = midroll
        }
    }
}

extension Model.Video.Item {
    public struct BrandedContent {
        
        public struct Tracker {
            public let impression: [URL]
            public let view: [URL]
            public let click: [URL]
            public let quartile1: [URL]
            public let quartile2: [URL]
            public let quartile3: [URL]
            public let quartile4: [URL]
            
            public init(impression: [URL],
                        view: [URL],
                        click: [URL],
                        quartile1: [URL],
                        quartile2: [URL],
                        quartile3: [URL],
                        quartile4: [URL]) {
                self.impression = impression
                self.view = view
                self.click = click
                self.quartile1 = quartile1
                self.quartile2 = quartile2
                self.quartile3 = quartile3
                self.quartile4 = quartile4
            }
        }
        
        public let advertisementText: String
        public let clickUrl: URL?
        public let tracker: Tracker?
        
        public init(advertisementText: String, clickUrl: URL?, tracker: Tracker?) {
            self.advertisementText = advertisementText
            self.clickUrl = clickUrl
            self.tracker = tracker
        }
    }
}

extension Model {
    public var prerolls: [Int] {
        return playlist.map {
            guard let prerollCount = $0.available?.ad.preroll.count else { return 0 }
            return prerollCount
        }
    }
}

extension Model {
    public var midrolls: [[PlayerCore.Midroll]] {
        return playlist.map {
            guard let available = $0.available else { return [] }
            return available.ad.midroll.map {
                return PlayerCore.Midroll(cuePoint: $0.cuePoint, url: $0.url)
            }
        }
    }
}

extension Model.Video.Item: Equatable {
    static public func == (lhs: Model.Video.Item, rhs: Model.Video.Item) -> Bool {
        return lhs.url == rhs.url
    }
}
