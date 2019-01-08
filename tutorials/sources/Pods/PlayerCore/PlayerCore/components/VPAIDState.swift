//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VPAIDState {
    public let events: [VPAIDEvents]
    public let adClickthrough: URL?
}

func reduce(state: VPAIDState, action: Action) -> VPAIDState {
    var events = state.events
    var clickUrl = state.adClickthrough
    switch action {
    case let ad as ShowAd:
        guard case .vpaid(let creative) = ad.creative else { return state }
        return VPAIDState(events: [], adClickthrough: creative.clickthrough)
    case is AdStopped,
         is AdRequest,
         is VRMCore.AdRequest,
         is ShowContent,
         is SelectVideoAtIdx:
        return VPAIDState(events: [], adClickthrough: nil)
    case is AdLoaded:
        events.append(.AdLoaded)
    case is AdNotSupported:
        events.append(.AdNotSupported)
    case is AdStarted:
        events.append(.AdStarted)
    case is AdStopped:
        events.append(.AdStopped)
    case is AdSkipped:
        events.append(.AdSkipped)
    case is AdPaused:
        events.append(.AdPaused)
    case is AdResumed:
        events.append(.AdResumed)
    case is AdImpression:
        events.append(.AdImpression)
    case is AdVideoStart:
        events.append(.AdVideoStart)
    case is AdVideoFirstQuartile:
        events.append(.AdVideoFirstQuartile)
    case is AdVideoMidpoint:
        events.append(.AdVideoMidpoint)
    case is AdVideoThirdQuartile:
        events.append(.AdVideoThirdQuartile)
    case is AdVideoComplete:
        events.append(.AdVideoComplete)
    case is AdUserAcceptInvitation:
        events.append(.AdUserAcceptInvitation)
    case is AdUserMinimize:
        events.append(.AdUserMinimize)
    case is AdUserClose:
        events.append(.AdUserClose)
    case is AdScriptLoaded:
        events.append(.AdScriptLoaded)
    case let action as AdDurationChange:
        events.append(.AdDurationChange(action.duration.seconds))
    case let action as AdCurrentTimeChanged:
        events.append(.AdCurrentTimeChanged(action.newTime.seconds))
    case let action as AdError:
        events.append(.AdError(action.error))
    case let action as AdVolumeChange:
        events.append(.AdVolumeChange(action.volume))
    case let action as AdClickThru:
        events.append(.AdClickThru(action.url))
        clickUrl = {
            guard let url = action.url else { return state.adClickthrough }
            return URL(string: url) ?? state.adClickthrough
        }()
    case let action as AdWindowOpen:
        clickUrl = action.url
    default: break
    }
    return VPAIDState(events: events,
                      adClickthrough: clickUrl)
}

