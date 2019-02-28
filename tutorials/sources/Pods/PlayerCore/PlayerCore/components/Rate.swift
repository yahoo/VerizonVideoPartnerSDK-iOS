//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

public enum VideoKind { case ad, content }

public struct Rate {
    public let contentRate: Value
    public let adRate: Value
    public let isAttachedToViewPort: Bool
    public let currentKind: VideoKind
    
    public struct Value {
        public let player: Bool
        public let stream: Bool
    }
}

func reduce(state: Rate, action: Action) -> Rate {
    switch (action, state.currentKind) {
        
    case (let action as SelectVideoAtIdx, _):
        if action.hasPrerollAds {
            return Rate(contentRate: .init(player: false, stream: false),
                        adRate: .init(player: true, stream: false),
                        isAttachedToViewPort: state.isAttachedToViewPort,
                        currentKind: .ad)
        } else {
            return Rate(contentRate: .init(player: true, stream: false),
                        adRate: .init(player: false, stream: false),
                        isAttachedToViewPort: state.isAttachedToViewPort,
                        currentKind: .content)
        }
        
    case (is Play, .content):
        return Rate(contentRate: .init(player: true,
                                       stream: state.contentRate.stream),
                    adRate: .init(player: false,
                                  stream: state.adRate.stream),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: state.currentKind)
        
    case (is Play, .ad):
        return Rate(contentRate: .init(player: false,
                                       stream: state.contentRate.stream),
                    adRate: .init(player: true,
                                  stream: state.adRate.stream),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: state.currentKind)
        
    case (is Pause, _):
        return Rate(contentRate: .init(player: false,
                                       stream: state.contentRate.stream),
                    adRate: .init(player: false,
                                  stream: state.adRate.stream),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: state.currentKind)
        
    case (is ShowContent, .ad), (is DropAd, .ad):
        return Rate(contentRate: .init(player: true,
                                       stream: state.contentRate.stream),
                    adRate: .init(player: false,
                                  stream: state.adRate.stream),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: .content)
        
    case (is ShowMP4Ad, .content), (is ShowVPAIDAd, .content):
        return Rate(contentRate: .init(player: false,
                                       stream: state.contentRate.stream),
                    adRate: .init(player: true,
                                  stream: state.adRate.stream),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: .ad)
        
    case (let action as UpdateContentStreamRate, .content):
        return Rate(contentRate: .init(player: state.contentRate.player,
                                       stream: action.rate),
                    adRate: state.adRate,
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: state.currentKind)
                
    case (let action as UpdateAdStreamRate, .ad):
        return Rate(contentRate: state.contentRate,
                    adRate: .init(player: state.adRate.player,
                                  stream: action.rate),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: state.currentKind)
        
    case (is CompletePlaybackSession, _):
        return Rate(contentRate: .init(player: false, stream: false),
                    adRate: .init(player: false, stream: false),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: state.currentKind)
        
    case (is AdPlaybackFailed, .ad):
        return Rate(contentRate: .init(player: true, stream: false),
                    adRate: .init(player: false, stream: false),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: .content)
        
    case (is ContentDidPlay, .content):
        return Rate(contentRate: .init(player: true, stream: state.contentRate.stream),
                    adRate: .init(player: false, stream: false),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: state.currentKind)
        
    case (is ContentDidPause, .content) where state.isAttachedToViewPort:
        return Rate(contentRate: .init(player: false, stream: state.contentRate.stream),
                    adRate: .init(player: false, stream: false),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: state.currentKind)
        
    case (is AdDidPlay, .ad):
        return Rate(contentRate: .init(player: false, stream: false),
                    adRate: .init(player: true, stream: state.adRate.stream),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: state.currentKind)
        
    case (is AdDidPause, .ad) where state.isAttachedToViewPort:
        return Rate(contentRate: .init(player: false, stream: false),
                    adRate: .init(player: false, stream: state.adRate.stream),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: state.currentKind)
        
    case (is AttachToViewport, _):
        return Rate(contentRate: state.contentRate,
                    adRate: state.adRate,
                    isAttachedToViewPort: true,
                    currentKind: state.currentKind)
        
    case (is DetachFromViewport, _):
        return Rate(contentRate: state.contentRate,
                    adRate: state.adRate,
                    isAttachedToViewPort: false,
                    currentKind: state.currentKind)
   
    case (is VPAIDActions.AdStarted, .ad) where state.isAttachedToViewPort:
        return Rate(contentRate: .init(player: false, stream: false),
                    adRate: .init(player: true, stream: state.adRate.stream),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: state.currentKind)
    
    case (is VPAIDActions.AdImpression, .ad) where state.isAttachedToViewPort:
        return Rate(contentRate: .init(player: false, stream: false),
                    adRate: .init(player: state.adRate.player, stream: true),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: state.currentKind)
        
    case (is VPAIDActions.AdPaused, .ad) where state.isAttachedToViewPort:
        return Rate(contentRate: .init(player: false, stream: false),
                    adRate: .init(player: false, stream: false),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: state.currentKind)
        
    case (is VPAIDActions.AdResumed, .ad) where state.isAttachedToViewPort:
        return Rate(contentRate: .init(player: false, stream: false),
                    adRate: .init(player: true, stream: true),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: state.currentKind)
        
    case (let action as DidHideAdClickthrough, .ad):
        let streamRate = action.isAdVPAID ? true : state.adRate.stream
        return Rate(contentRate: .init(player: false, stream: false),
                    adRate: .init(player: true, stream: streamRate),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: state.currentKind)
        
    case (is VPAIDActions.AdStopped, .ad),
         (is VPAIDActions.AdNotSupported, .ad),
         (is VPAIDActions.AdSkipped, .ad),
         (is VPAIDActions.AdError, .ad),
         (is SkipAd, .ad),
         (is AdStartTimeout, .ad),
         (is AdMaxShowTimeout, .ad):
        return Rate(contentRate: .init(player: true,
                                       stream: state.contentRate.stream),
                    adRate: .init(player: false,
                                  stream: false),
                    isAttachedToViewPort: state.isAttachedToViewPort,
                    currentKind: .content)
    default: return state
    }
}
