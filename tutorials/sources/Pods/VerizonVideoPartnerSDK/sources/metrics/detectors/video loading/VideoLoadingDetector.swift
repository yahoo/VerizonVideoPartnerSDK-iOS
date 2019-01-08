//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

enum Detectors {
    final class VideoLoading {
        enum Result {
            case nothing
            case beginLoading
            case endLoading
        }
        
        var isLoading = false
        var isLoaded = false
        var sessionID = UUID()
        
        func render(isLoaded: Bool,
                    sessionID: UUID?,
                    isPlaying: Bool) -> Result {
            guard let sessionID = sessionID else { return .nothing }
            if self.sessionID != sessionID {
                self.sessionID = sessionID
                self.isLoading = false
                self.isLoaded = false
            }
            
            guard isPlaying else { return .nothing }
            
            if isLoading == false {
                isLoading = true
                return .beginLoading
            } else if isLoaded == true && self.isLoaded == false {
                self.isLoaded = true
                return .endLoading
            } else {
                return .nothing
            }
        }
        
        func renderContent(props: Player.Properties) -> Result {
            guard let item = props.playbackItem else { return .nothing }
            return render(isLoaded: item.content.status.isReady,
                          sessionID: props.session.playback.id,
                          isPlaying: true)
        }
        
        func renderAd(props: Player.Properties) -> Result {
            guard let item = props.playbackItem else { return .nothing }
            return render(isLoaded: item.ad.status.isReady,
                          sessionID: props.adSessionID,
                          isPlaying: item.isAdPlaying)
        }
    }
}
