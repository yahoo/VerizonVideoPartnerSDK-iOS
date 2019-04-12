//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public enum AdType {
    case preroll, midroll
}

public struct Ad {
    public let playedAds: Set<UUID>
    public let midrolls: [Midroll]
    
    public struct Midroll: Hashable {
        public let cuePoint: Int
        public let url: URL
        public let id: UUID
    }
    
    public enum State: Hashable {
        case empty
        case play
        
        public var isPlaying: Bool {
            guard case .play = self else { return false }
            return true
        }
    }
    public let mp4AdCreative: AdCreative.MP4?
    public let vpaidAdCreative: AdCreative.VPAID?
    
    public let currentAd: State
    public let currentType: AdType
}

func reduce(state: Ad, action: Action) -> Ad {
    
    func markIDAsPlayed(id: UUID) -> Ad {
        var playedAds = state.playedAds
        playedAds.insert(id)
        return Ad(playedAds: playedAds,
                  midrolls: state.midrolls,
                  mp4AdCreative: state.mp4AdCreative,
                  vpaidAdCreative: state.vpaidAdCreative,
                  currentAd: state.currentAd,
                  currentType: state.currentType)
    }
    
    switch action {
    case let action as VRMCore.AdRequest:
        return Ad(playedAds: state.playedAds,
                  midrolls: state.midrolls,
                  mp4AdCreative: nil,
                  vpaidAdCreative: nil,
                  currentAd: state.currentAd,
                  currentType: action.type)
        
    case let action as ShowMP4Ad:
        var playedAds = state.playedAds
        playedAds.insert(action.id)
        return Ad(playedAds: playedAds,
                  midrolls: state.midrolls,
                  mp4AdCreative: action.creative,
                  vpaidAdCreative: nil,
                  currentAd: .play,
                  currentType: state.currentType)
        
    case let action as ShowVPAIDAd:
        var playedAds = state.playedAds
        playedAds.insert(action.id)
        return Ad(playedAds: playedAds,
                  midrolls: state.midrolls,
                  mp4AdCreative: nil,
                  vpaidAdCreative: action.creative,
                  currentAd: .play,
                  currentType: state.currentType)
        
    case let action as VRMCore.VRMResponseFetchFailed:
        return markIDAsPlayed(id: action.requestID)
        
    case let action as VRMCore.NoGroupsToProcess:
        var playedAds = state.playedAds
        playedAds.insert(action.id)
        return Ad(playedAds: playedAds,
                  midrolls: state.midrolls,
                  mp4AdCreative: nil,
                  vpaidAdCreative: nil,
                  currentAd: .empty,
                  currentType: state.currentType)
        
    case let action as VRMCore.MaxSearchTimeout:
        return markIDAsPlayed(id: action.requestID)
        
    case is VPAIDAdStartTimeout,
         is VPAIDActions.AdError,
         is VPAIDActions.AdNotSupported:
        return Ad(playedAds: state.playedAds,
                  midrolls: state.midrolls,
                  mp4AdCreative: state.mp4AdCreative,
                  vpaidAdCreative: nil,
                  currentAd: state.currentAd,
                  currentType: state.currentType)
        
    case is ShowContent,
         is SkipAd,
         is DropAd,
         is AdPlaybackFailed,
         is MP4AdStartTimeout,
         is AdMaxShowTimeout,
         is VRMCore.MaxSearchTimeout,
         is VPAIDActions.AdStopped,
         is VPAIDActions.AdSkipped:
        return Ad(playedAds: state.playedAds,
                  midrolls: state.midrolls,
                  mp4AdCreative: state.mp4AdCreative,
                  vpaidAdCreative: state.vpaidAdCreative,
                  currentAd: .empty,
                  currentType: state.currentType)
        
    case let action as SelectVideoAtIdx:
        return Ad(playedAds: [],
                  midrolls: action.midrolls,
                  mp4AdCreative: nil,
                  vpaidAdCreative: nil,
                  currentAd: .empty,
                  currentType: action.hasPrerollAds ? .preroll : .midroll)
        
    default: return state
    }
}
