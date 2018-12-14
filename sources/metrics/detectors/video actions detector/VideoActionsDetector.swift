//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    final class VideoActions {
        enum Result { case nothing, didPause, didPlay }
        
        typealias ActionInitiated = Player.Properties.PlaybackItem.Video.ActionInitiated
        var prevActionInitiated: ActionInitiated = .unknown
        
        func render(actionInitiated: ActionInitiated, isAutoplay: Bool) -> Result {
            guard actionInitiated != .unknown else { return .nothing }
            guard actionInitiated != prevActionInitiated else { return .nothing }
            
            let result: Result
            switch (actionInitiated, prevActionInitiated, isAutoplay) {
            case (.play, .unknown, false): result = .didPlay
            case (.play, .pause, _): result = .didPlay
            case (.pause, .play, _): result = .didPause
            case (.pause, .unknown, true): result = .nothing
            default: result = .nothing
            }
            
            prevActionInitiated = actionInitiated
            
            return result
        }
        
        func renderContent(_ props: Player.Properties) -> Result {
            guard let item = props.playbackItem else { return .nothing }
            return render(actionInitiated: item.content.actionInitiated,
                          isAutoplay: props.isAutoplayEnabled)
        }
        
        func renderAd(_ props: Player.Properties) -> Result {
            guard let item = props.playbackItem else { return .nothing }

            return render(actionInitiated: item.ad.actionInitiated,
                          isAutoplay: props.isAutoplayEnabled)
        }
    }
}
