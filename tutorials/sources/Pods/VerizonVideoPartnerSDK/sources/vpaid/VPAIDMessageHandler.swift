//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import WebKit
import PlayerCore

final class VPAIDMessageHandler: NSObject, WKScriptMessageHandler {
    let dispatch: (VPAIDEvents) -> ()
    
    init(dispatch: @escaping (VPAIDEvents) -> ()) {
        self.dispatch = dispatch
        super.init()
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "observer" else { return }
        guard let body = message.body as? String else { return }
        guard let data = body.data(using: .utf8) else { return }
        let decoder = JSONDecoder()
        guard let result = try? decoder.decode(WebKitMessage.self, from: data) else { return }
        guard let event = Events(rawValue: result.name) else { return }
        switch event {
        case .AdNotSupported: dispatch(.AdNotSupported)
        case .AdDurationChange:
            guard let value = result.value, let time = Double(value) else { return }
            self.dispatch(.AdDurationChange(time))
        case .AdCurrentTimeChanged:
            guard let value = result.value, let time = Double(value) else { return }
            dispatch(.AdCurrentTimeChanged(time))
        case .AdLoaded:
            dispatch(.AdLoaded)
        case .AdStarted:
            dispatch(.AdStarted)
        case .AdStopped:
            dispatch(.AdStopped)
        case .AdSkipped:
            dispatch(.AdSkipped)
        case .AdPaused:
            dispatch(.AdPaused)
        case .AdResumed:
            dispatch(.AdResumed)
        case .AdImpression:
            dispatch(.AdImpression)
        case .AdVideoStart:
            dispatch(.AdVideoStart)
        case .AdVideoFirstQuartile:
            dispatch(.AdVideoFirstQuartile)
        case .AdVideoMidpoint:
            dispatch(.AdVideoMidpoint)
        case .AdVideoThirdQuartile:
            dispatch(.AdVideoThirdQuartile)
        case .AdVideoComplete:
            dispatch(.AdVideoComplete)
        case .AdClickThru:
            let clickOptions: (url: String?, isPlayerHandles: Bool) = {
                guard let data = result.value?.data(using: .utf8) else { return (nil, true) }
                guard let options = try? decoder.decode(ClickthroughOptions.self, from: data) else { return (nil, true) }
                return (options.url, options.isPlayerHandles)
            }()
            dispatch(.AdClickThru(clickOptions.url))
        case .AdError: dispatch(.AdError(NSError(domain: "Impossible to load VPAID ad.",
                                                 code: 901,
                                                 userInfo: nil)))
        case .AdUserAcceptInvitation:
            dispatch(.AdUserAcceptInvitation)
        case .AdUserMinimize:
            dispatch(.AdUserMinimize)
        case .AdUserClose:
            dispatch(.AdUserClose)
        case .AdVolumeChange:
            guard let value = result.value, let volume = Float(value) else { return }
            dispatch(.AdVolumeChange(volume))
        case .AdScriptLoaded:
            dispatch(.AdScriptLoaded)
        case .UniqueEventError:
            guard let data = result.value?.data(using: .utf8),
                  let errorInfo = try? decoder.decode(UniqueEventError.self, from: data) else { return }
                dispatch(.AdUniqueEventAbuse(name: errorInfo.name, value: errorInfo.value))
        }
    }
    struct WebKitMessage: Codable {
        let name: String
        let value: String?
    }
    struct ClickthroughOptions: Codable {
        let url: String?
        let isPlayerHandles: Bool
    }
    struct UniqueEventError: Codable {
        let name: String
        let value: String?
    }
    enum Events: String {
        case AdDurationChange
        case AdCurrentTimeChanged
        case AdLoaded
        case AdNotSupported
        case AdStarted
        case AdStopped
        case AdSkipped
        case AdPaused
        case AdResumed
        case AdClickThru
        case AdError
        case AdImpression
        case AdVideoStart
        case AdVideoFirstQuartile
        case AdVideoMidpoint
        case AdVideoThirdQuartile
        case AdVideoComplete
        case AdUserAcceptInvitation
        case AdUserMinimize
        case AdUserClose
        case AdVolumeChange
        case AdScriptLoaded
        case UniqueEventError
    }
}

