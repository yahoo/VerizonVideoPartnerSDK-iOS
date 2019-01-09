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
        return AdDurationChange(duration: time)
    case .AdCurrentTimeChanged(let currentTime):
        let time = CMTime(seconds: currentTime, preferredTimescale: 600)
        return AdCurrentTimeChanged(newTime: time)
    case .AdClickThru(let url):
        return AdClickThru(url: url)
    case .AdLoaded:
        return AdLoaded()
    case .AdNotSupported:
        return AdNotSupported()
    case .AdStarted:
        return AdStarted()
    case .AdStopped:
        return AdStopped()
    case .AdSkipped:
        return AdSkipped()
    case .AdPaused:
        return AdPaused()
    case .AdResumed:
        return AdResumed()
    case .AdError(let error):
        return AdError(error: error)
    case .AdImpression:
        return AdImpression()
    case .AdVideoStart:
        return AdVideoStart()
    case .AdVideoFirstQuartile:
        return AdVideoFirstQuartile()
    case .AdVideoMidpoint:
        return AdVideoMidpoint()
    case .AdVideoThirdQuartile:
        return AdVideoThirdQuartile()
    case .AdVideoComplete:
        return AdVideoComplete()
    case .AdWindowOpen(let url):
        return AdWindowOpen(url: url)
    case .AdUserAcceptInvitation:
        return AdUserAcceptInvitation()
    case .AdUserMinimize:
        return AdUserMinimize()
    case .AdUserClose:
        return AdUserClose()
    case .AdVolumeChange(let volume):
        return AdVolumeChange(volume: volume)
    case .AdScriptLoaded:
        return AdScriptLoaded()
    case let .AdUniqueEventAbuse(name, value):
        return AdUniqueEventAbuse(name: name, value: value)
    case .AdJSEvaluationFailed(let error):
        return AdJavaScriptEvaluationError(error: error)
    }
}

