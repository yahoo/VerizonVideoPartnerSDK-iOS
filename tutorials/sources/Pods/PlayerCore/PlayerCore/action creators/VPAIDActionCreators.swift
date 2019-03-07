//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreMedia

public enum VPAIDEvents {
    case AdDurationChange(Double)
    case AdCurrentTimeChanged(Double)
    case AdLoaded
    case AdNotSupported
    case AdStarted
    case AdStopped
    case AdSkipped
    case AdPaused
    case AdResumed
    case AdClickThru(String?)
    case AdError(Error)
    case AdJSEvaluationFailed(Error)
    case AdImpression
    case AdVideoStart
    case AdVideoFirstQuartile
    case AdVideoMidpoint
    case AdVideoThirdQuartile
    case AdVideoComplete
    case AdWindowOpen(URL)
    case AdUserAcceptInvitation
    case AdUserMinimize
    case AdUserClose
    case AdVolumeChange(Float)
    case AdScriptLoaded
    case AdUniqueEventAbuse(name: String, value: String?)
}

public func createAction(from event: VPAIDEvents) -> Action {
    switch event {
    case .AdDurationChange(let duration):
        let time = CMTime(seconds: duration, preferredTimescale: 600)
        return VPAIDActions.AdDurationChange(duration: time)
    case .AdCurrentTimeChanged(let currentTime):
        let time = CMTime(seconds: currentTime, preferredTimescale: 600)
        return VPAIDActions.AdCurrentTimeChanged(newTime: time)
    case .AdClickThru(let url):
        return VPAIDActions.AdClickThru(url: url)
    case .AdLoaded:
        return VPAIDActions.AdLoaded()
    case .AdNotSupported:
        return VPAIDActions.AdNotSupported()
    case .AdStarted:
        return VPAIDActions.AdStarted()
    case .AdStopped:
        return VPAIDActions.AdStopped()
    case .AdSkipped:
        return VPAIDActions.AdSkipped()
    case .AdPaused:
        return VPAIDActions.AdPaused()
    case .AdResumed:
        return VPAIDActions.AdResumed()
    case .AdError(let error):
        return VPAIDActions.AdError(error: error)
    case .AdImpression:
        return VPAIDActions.AdImpression()
    case .AdVideoStart:
        return VPAIDActions.AdVideoStart()
    case .AdVideoFirstQuartile:
        return VPAIDActions.AdVideoFirstQuartile()
    case .AdVideoMidpoint:
        return VPAIDActions.AdVideoMidpoint()
    case .AdVideoThirdQuartile:
        return VPAIDActions.AdVideoThirdQuartile()
    case .AdVideoComplete:
        return VPAIDActions.AdVideoComplete()
    case .AdWindowOpen(let url):
        return VPAIDActions.AdWindowOpen(url: url)
    case .AdUserAcceptInvitation:
        return VPAIDActions.AdUserAcceptInvitation()
    case .AdUserMinimize:
        return VPAIDActions.AdUserMinimize()
    case .AdUserClose:
        return VPAIDActions.AdUserClose()
    case .AdVolumeChange(let volume):
        return VPAIDActions.AdVolumeChange(volume: volume)
    case .AdScriptLoaded:
        return VPAIDActions.AdScriptLoaded()
    case let .AdUniqueEventAbuse(name, value):
        return VPAIDActions.AdUniqueEventAbuse(name: name, value: value)
    case .AdJSEvaluationFailed(let error):
        return VPAIDActions.AdJavaScriptEvaluationError(error: error)
    }
}

