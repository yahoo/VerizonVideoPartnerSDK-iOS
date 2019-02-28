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
    case let ad as ShowVPAIDAd:
        return VPAIDState(events: [], adClickthrough: ad.creative.clickthrough)
    case is VPAIDActions.AdStopped,
         is VRMCore.SelectFinalResult,
         is ShowContent,
         is SkipAd,
         is SelectVideoAtIdx:
        return VPAIDState(events: [], adClickthrough: nil)
    case is VPAIDActions.AdLoaded:
        events.append(.AdLoaded)
    case is VPAIDActions.AdNotSupported:
        events.append(.AdNotSupported)
    case is VPAIDActions.AdStarted:
        events.append(.AdStarted)
    case is VPAIDActions.AdStopped:
        events.append(.AdStopped)
    case is VPAIDActions.AdSkipped:
        events.append(.AdSkipped)
    case is VPAIDActions.AdPaused:
        events.append(.AdPaused)
    case is VPAIDActions.AdResumed:
        events.append(.AdResumed)
    case is VPAIDActions.AdImpression:
        events.append(.AdImpression)
    case is VPAIDActions.AdVideoStart:
        events.append(.AdVideoStart)
    case is VPAIDActions.AdVideoFirstQuartile:
        events.append(.AdVideoFirstQuartile)
    case is VPAIDActions.AdVideoMidpoint:
        events.append(.AdVideoMidpoint)
    case is VPAIDActions.AdVideoThirdQuartile:
        events.append(.AdVideoThirdQuartile)
    case is VPAIDActions.AdVideoComplete:
        events.append(.AdVideoComplete)
    case is VPAIDActions.AdUserAcceptInvitation:
        events.append(.AdUserAcceptInvitation)
    case is VPAIDActions.AdUserMinimize:
        events.append(.AdUserMinimize)
    case is VPAIDActions.AdUserClose:
        events.append(.AdUserClose)
    case is VPAIDActions.AdScriptLoaded:
        events.append(.AdScriptLoaded)
    case let action as VPAIDActions.AdDurationChange:
        events.append(.AdDurationChange(action.duration.seconds))
    case let action as VPAIDActions.AdCurrentTimeChanged:
        events.append(.AdCurrentTimeChanged(action.newTime.seconds))
    case let action as VPAIDActions.AdError:
        events.append(.AdError(action.error))
    case let action as VPAIDActions.AdVolumeChange:
        events.append(.AdVolumeChange(action.volume))
    case let action as VPAIDActions.AdClickThru:
        events.append(.AdClickThru(action.url))
        clickUrl = {
            guard let url = action.url else { return state.adClickthrough }
            return URL(string: url) ?? state.adClickthrough
        }()
    case let action as VPAIDActions.AdWindowOpen:
        clickUrl = action.url
    default: break
    }
    return VPAIDState(events: events,
                      adClickthrough: clickUrl)
}

