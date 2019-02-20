//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import CoreMedia

import PlayerCore
import VideoRenderer

public typealias Progress = PlayerCore.Progress

extension Player {
    public struct Properties {
        
        public struct Playlist {
            public let hasNextVideo: Bool
            public let hasPrevVideo: Bool
            public let count: Int
            public let currentIndex: Int
        }
        public let playlist: Playlist
        
        let isPlaybackInitiated: Bool
        let dimensions: CGSize?
        
        public let isAutoplayEnabled: Bool
        public let isMuted: Bool
        public let isVPAIDMuted: Bool
        public let isSessionCompleted: Bool
        
        let session: PlayerSession
        let adSessionID: UUID
        let vpaidDocument: URL
        
        struct PlayerSession {
            let age: Age
            
            struct Age {
                let seconds: TimeInterval
                let milliseconds: String
            }
            
            let playback: Playback
            
            struct Playback {
                let id: UUID
                let duration: TimeInterval
                let stallRecords: [StallRecord]
                
                struct StallRecord {
                    // miliseconds
                    let duration: Int
                    let timestamp: TimeInterval
                }
                
                let intentTime: TimeInterval?
                let intentElapsedTime: TimeInterval?
            }
        }
        
        public enum PlaybackItem {
            public struct Available {
                public let model: PlayerCore.Model.Video.Item
                public let hasActiveAds: Bool
                public let midrollPrefetchingOffset: Int
                public let playedAds: Set<UUID>
                public let midrolls: [PlayerCore.Ad.Midroll]
                public let adSkipOffset: Int?
                let mp4AdCreative: PlayerCore.AdCreative.MP4?
                let vpaidAdCreative: PlayerCore.AdCreative.VPAID?
                
                public let isAdPlaying: Bool
                public let content: Video
                public let ad: Video
                
                public let url: URL
                public let title: String
                
                public let videoAngles: (horizontal: Float, vertical: Float)?
                let isClickThroughToggled: Bool
                let vpaidClickthrough: URL?
                public let isLastVideo: Bool
                public let isReplayable: Bool
            }
            
            public struct Video {
                public let isStreamPlaying: Bool
                public let isPlaying: Bool
                public let isPaused: Bool
                public let isSeeking: Bool
                public let isSeekable: Bool
                public let isLoading: Bool
                public let isBuffering: Bool
                public enum ActionInitiated { case play, pause, unknown }
                public let actionInitiated: ActionInitiated
                public enum Status {
                    case undefined
                    case ready
                    case failed(Error)
                    
                    var isDefined: Bool {
                        guard case .undefined = self else { return true }
                        return false
                    }
                    
                    var isReady: Bool {
                        guard case .ready = self else { return false }
                        return true
                    }
                    
                    var isUndefined: Bool {
                        guard case .undefined = self else { return false }
                        return true
                    }
                }
                public let status: Status
                // Average video bitrate measured in kbit per seconds
                public let averageBitrate: Double?
                
                /// `Time` information about video.
                public enum Time {
                    case unknown
                    public var isUnknown: Bool {
                        guard case .unknown = self else  { return false }
                        return true
                    }
                    
                    case live(Live)
                    public var live: Live? {
                        guard case let .live(live) = self else { return nil }
                        return live
                    }
                    public var isLive: Bool {
                        return live != nil
                    }
                    
                    case `static`(Static)
                    public var `static`: Static? {
                        guard case let .`static`(`static`) = self else { return nil }
                        return `static`
                    }
                    public var isStatic: Bool {
                        return `static` != nil
                    }
                    
                    public struct Live {
                        public let isFinished: Bool
                    }
                    
                    public struct Static {
                        public let progress: Progress
                        public let currentCMTime: CMTime?
                        public let current: Double?
                        public let duration: Double
                        public let hasDuration: Bool
                        public let remaining: Double
                        public let lastPlayedDecile: Int
                        public let lastPlayedQuartile: Int
                        public let isFinished: Bool
                    }
                }
                
                public let time: Time
                
                public struct BufferInfo {
                    let progress: Progress
                    let time: CMTime
                    let milliseconds: Int
                }
                public let bufferInfo: BufferInfo
                
                public enum PictureInPictureMode {
                    case unsupported, possible, impossible, active
                }
                
                public let pictureInPictureMode: PictureInPictureMode
                
                public let controlsAnimationSupport: Bool
                
                public enum ContentFullScreenMode {
                    case inactive, active, disabled
                }
                
                public let contentFullScreen: ContentFullScreenMode
                
                public enum AirPlay {
                    case inactive, restricted, active, disabled
                    
                    public var isAble: Bool {
                        return self != .restricted && self != .disabled
                    }
                }
                
                public let airPlay: AirPlay
                
                public enum Subtitles {
                    case `internal`(MediaGroup?)
                    case external(External)
                    public struct External {
                        public let isActive: Bool
                        public let isLoading: Bool
                        public let isLoaded: Bool
                        public let text: String
                        public let group: MediaGroup
                    }
                }
                
                public struct MediaGroup {
                    public let options: [Option]
                    
                    public struct Option {
                        public let id: UUID
                        public let displayName: String
                        public let selected: Bool
                    }
                    
                    public static func empty() -> MediaGroup {
                        return MediaGroup(options: [])
                    }
                    
                    public var selectedOption: Option? {
                        return options.first { $0.selected }
                    }
                }
                
                public let audible: MediaGroup
                public let legible: Subtitles
            }
            
            case available(Available)
            
            public struct Unavailable {
                public let reason: String
            }
            case unavailable(Unavailable)
        }
        public let item: PlaybackItem
        
        public var playbackItem: PlaybackItem.Available? {
            guard case .available(let available) = item else { return nil }
            return available
        }
        
        public var errorItem: PlaybackItem.Unavailable? {
            guard case .unavailable(let unavailable) = item else { return nil }
            return unavailable
        }
        
        // Measured from 0 - 100
        public let volume: Int
    }
}

func perform<T>(code: () throws -> T) rethrows -> T {
    return try code()
}
