//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

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
    case let action as AdRequest:
        return Ad(playedAds: state.playedAds,
                  midrolls: state.midrolls,
                  mp4AdCreative: nil,
                  vpaidAdCreative: nil,
                  currentAd: state.currentAd,
                  currentType: action.type)
        
    case let action as VRMCore.AdRequest:
        return Ad(playedAds: state.playedAds,
                  midrolls: state.midrolls,
                  mp4AdCreative: nil,
                  vpaidAdCreative: nil,
                  currentAd: state.currentAd,
                  currentType: action.type)
        
    case let action as ShowAd:
        var playedAds = state.playedAds
        playedAds.insert(action.id)
        switch action.creative {
        case .mp4(let creatives):
            return Ad(playedAds: playedAds,
                      midrolls: state.midrolls,
                      mp4AdCreative: creatives.first,
                      vpaidAdCreative: nil,
                      currentAd: .play,
                      currentType: state.currentType)
        case .vpaid(let creatives):
            return Ad(playedAds: playedAds,
                      midrolls: state.midrolls,
                      mp4AdCreative: nil,
                      vpaidAdCreative: creatives.first,
                      currentAd: .play,
                      currentType: state.currentType)
        case .none:
            fatalError("AdCreative.none has to create SkipAd action")
        }
        
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
        
    case let action as DropAd:
        return markIDAsPlayed(id: action.id)
        
    case let action as VRMCore.VRMResponseFetchFailed:
        return markIDAsPlayed(id: action.requestID)
        
    case let action as VRMCore.NoGroupsToProcess:
        return markIDAsPlayed(id: action.id)
        
    case let action as VRMCore.MaxSearchTimeout:
        return markIDAsPlayed(id: action.requestID)
        
    case is ShowContent,
         is SkipAd,
         is AdPlaybackFailed,
         is AdError,
         is AdStartTimeout,
         is AdMaxShowTimeout,
         is AdStopped,
         is AdSkipped,
         is AdNotSupported:
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
