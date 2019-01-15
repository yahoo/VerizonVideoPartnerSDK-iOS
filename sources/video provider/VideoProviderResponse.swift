//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension VideoProvider {
    public struct Response {
        public let videos: [VideoResponse]
        public let tracking: Tracking
        public let autoplay: Bool
        public let features: Features
        public let adSettings: AdSettings
        
        enum Error: Swift.Error {
            case emptyVideos
        }
        
        public init(videos: [VideoResponse],
                    tracking: Tracking,
                    autoplay: Bool,
                    features: Features,
                    adSettings: AdSettings) throws {
            guard videos.count > 0 else { throw Error.emptyVideos }
            
            self.videos = videos
            self.tracking = tracking
            self.autoplay = autoplay
            self.features = features
            self.adSettings = adSettings
        }
    }
}
extension VideoProvider.Response {
    
    public struct Features {
        public let isControlsAnimationEnabled: Bool
        public let isVPAIDAllowed: Bool
        public let isOpenMeasurementEnabled: Bool
        public let isNewVRMCoreEnabled: Bool
    }
    
    public struct AdSettings {
        public let prefetchingOffset: Int
        public let softTimeout: Double
        public let hardTimeout: Double
        public let startTimeout: Double
        public let maxDuration: Int
        public let maxVASTWrapperRedirectCount: Int
    }
    
    public enum Tracking {
        case native(Native)
        case javascript(JSON)
        
        public struct Native {
            public let adURL: URL
            public let trkURL: URL
            public let pid: String
            public let appID: String
            public let bcid: String
            public let uuid: String
            public let siteSection: String
            public let playerVersion: String
            public let playerType: String
            public let videoIds: [String]
            public let playlistId: String?
            public let sessionId: String
            public let referringURLString: String
            public let platformSupport: String
            public let vcdn: [String]?
            public let apid: String?
            public let vcid: [String?]?
            public let mpid: [String?]?
            
            public enum Error: Swift.Error {
                case emptyPid
                case emptyBcid
                case emptyAppID
                case emptyUUID
                case emptySiteSection
                case emptyPlayerVersion
                case emptyPlayerType
                case emptyVideoIds
                case emptySessionID
                case emptyReferringURLString
                case emptyPlatformSupport
            }
            
            public init(adURL: URL,
                        trkURL: URL,
                        pid: String,
                        appID: String,
                        bcid: String,
                        uuid: String,
                        siteSection: String,
                        playerVersion: String,
                        playerType: String,
                        videoIds: [String],
                        playlistId: String?,
                        sessionId: String,
                        referringURLString: String,
                        platformSupport: String,
                        vcdn: [String]?,
                        apid: String?,
                        vcid: [String?]?,
                        mpid: [String?]?) throws {
                
                guard !pid.isEmpty else { throw Error.emptyPid }
                guard !bcid.isEmpty else { throw Error.emptyBcid }
                guard !appID.isEmpty else { throw Error.emptyAppID }
                guard !uuid.isEmpty else { throw Error.emptyUUID }
                guard !playerVersion.isEmpty else { throw Error.emptyPlayerVersion }
                guard !playerType.isEmpty else { throw Error.emptyPlayerType }
                guard !videoIds.isEmpty else { throw Error.emptyVideoIds }
                guard !sessionId.isEmpty else { throw Error.emptySessionID }
                guard !referringURLString.isEmpty else { throw Error.emptyReferringURLString}
                guard !platformSupport.isEmpty else { throw Error.emptyPlatformSupport }
                
                self.pid = pid
                self.bcid = bcid
                self.appID = appID
                self.uuid = uuid
                self.trkURL = trkURL
                self.adURL = adURL
                self.siteSection = siteSection
                self.playerVersion = playerVersion
                self.playerType = playerType
                self.videoIds = videoIds
                self.playlistId = playlistId
                self.sessionId = sessionId
                self.referringURLString = referringURLString
                self.platformSupport = platformSupport
                self.vcdn = vcdn
                self.apid = apid
                self.vcid = vcid
                self.mpid = mpid
            }
        }
    }
    
    public enum VideoResponse {
        case video(Video)
        case restricted(reason: String)
        case missing(reason: String)
        case invalid(reason: String)
        case missingRenderer(Video.Descriptor)
    }
    
    public struct Video {
        public struct BrandedContent {
            
            public struct Tracker {
                public let impression: [URL]
                public let view: [URL]
                public let click: [URL]
                public let quartile1: [URL]
                public let quartile2: [URL]
                public let quartile3: [URL]
                public let quartile4: [URL]
            }
            
            public let advertisementText: String
            public let clickUrl: URL?
            public let tracker: Tracker?
        }
        
        public struct Descriptor: Hashable {
            public let id: String
            public let version: String
            
            public enum Error: Swift.Error {
                case emptyID, emptyVersion
            }
            
            /// Throw error in case of empty id or version values
            public init(id: String, version: String) throws {
                guard !id.isEmpty else { throw Error.emptyID }
                guard !version.isEmpty else { throw Error.emptyVersion }
                
                self.id = id
                self.version = version
            }
        }
        public let id: String
        public let url: URL
        let title: String
        let thumbnails: [Thumbnail]
        let renderer: Descriptor
        let pods: [Pod]
        let isScreenCastingEnabled: Bool
        let isPictureInPictureEnabled: Bool
        let brandedContent: BrandedContent?
    }
    
    struct Thumbnail {
        let width: Float
        let height: Float
        let url: URL
        
        enum Error: Swift.Error {
            case negativeWidth(Float)
            case negativeHeight(Float)
            case zeroWidth(Float)
            case zeroHeight(Float)
        }
        
        init(width: Float, height: Float, url: URL) throws {
            guard width >= 0 else { throw Error.negativeWidth(width) }
            guard height >= 0 else { throw Error.negativeHeight(height) }
            guard width > 0 else { throw Error.zeroWidth(width) }
            guard height > 0 else { throw Error.zeroHeight(height) }
            
            self.width = width
            self.height = height
            self.url = url
        }
    }
    
    enum Renderer {
        case flat
        case sphere
    }
    
    struct Pod {
        let time: PodTime
        let url: URL
        
        init (time: PodTime, url: URL) throws {
            self.time = time
            self.url = url
        }
    }
    
    enum PodTime {
        case preroll
        case postroll
        case seconds(Int)
    }
}
