//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public struct Ad {
    public let playedAds: Set<UUID>
    public let midrolls: [Midroll]
    
    public struct Midroll {
        public let cuePoint: Int
        public let url: URL
        public let id: UUID
    }
    
    public enum State {
        case empty
        case play
        
        public var isPlaying: Bool {
            guard case .play = self else { return false }
            return true
        }
    }
    public var adCreative: AdCreative
    
    public let currentAd: State
    public let currentType: AdType
}

func reduce(state: Ad, action: Action) -> Ad {
    switch action {
    case let action as AdRequest:
        return Ad(playedAds: state.playedAds,
                  midrolls: state.midrolls,
                  adCreative: .none,
                  currentAd: state.currentAd,
                  currentType: action.type)
        
    case let action as VRMCore.AdRequest:
        return Ad(playedAds: state.playedAds,
                  midrolls: state.midrolls,
                  adCreative: .none,
                  currentAd: state.currentAd,
                  currentType: action.type)
        
    case let action as ShowAd:
        var playedAds = state.playedAds
        playedAds.insert(action.id)
        return Ad(playedAds: playedAds,
                  midrolls: state.midrolls,
                  adCreative: action.creative,
                  currentAd: .play,
                  currentType: state.currentType)
        
    case let action as SkipAd:
        var playedAds = state.playedAds
        playedAds.insert(action.id)
        return Ad(playedAds: playedAds,
                  midrolls: state.midrolls,
                  adCreative: state.adCreative,
                  currentAd: state.currentAd,
                  currentType: state.currentType)
        
    case let action as VRMCore.VRMResponseFetchFailed:
        var playedAds = state.playedAds
        playedAds.insert(action.requestID)
        return Ad(playedAds: playedAds,
                  midrolls: state.midrolls,
                  adCreative: state.adCreative,
                  currentAd: state.currentAd,
                  currentType: state.currentType)
        
    case is ShowContent,
         is AdPlaybackFailed,
         is AdError,
         is AdStartTimeout,
         is AdMaxShowTimeout,
         is AdStopped,
         is AdSkipped,
         is AdNotSupported:
        return Ad(playedAds: state.playedAds,
                  midrolls: state.midrolls,
                  adCreative: state.adCreative,
                  currentAd: .empty,
                  currentType: state.currentType)
        
    case let action as SelectVideoAtIdx:
        return Ad(playedAds: [],
                  midrolls: action.midrolls,
                  adCreative: .none,
                  currentAd: .empty,
                  currentType: action.hasPrerollAds ? .preroll : .midroll)
        
    default: return state
    }
}

extension Ad.Midroll: Equatable {
    public static func ==(lhs: Ad.Midroll, rhs: Ad.Midroll) -> Bool {
        return lhs.cuePoint == rhs.cuePoint
            && lhs.url == rhs.url
            && lhs.id == rhs.id
    }
    
    public static func >(left: Ad.Midroll, right: Ad.Midroll) -> Bool {
        return left.cuePoint > right.cuePoint
    }
    
    public static func <(left: Ad.Midroll, right: Ad.Midroll) -> Bool {
        return left.cuePoint < right.cuePoint
    }
}
