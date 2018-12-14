//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import UIKit
import PlayerCore

final class StartAdProcessingController {
    
    let dispatch: (PlayerCore.Action) -> Void
    
    private var sessionID = UUID()
    private var isPrerollRequested = false
    
    init(dispatch: @escaping (PlayerCore.Action) -> Void) {
        self.dispatch = dispatch
    }
    
    func process(props: Player.Properties) {
        process(with: props.playbackItem?.model.ad.preroll.first?.url,
                isPlaybackInitiated: props.isPlaybackInitiated,
                sessionID: props.session.playback.id)
    }
    
    func process(with url: URL?,
                 isPlaybackInitiated: Bool,
                 sessionID: UUID) {
        guard let url = url,
            isPlaybackInitiated else { return }
        
        if self.sessionID != sessionID {
            self.sessionID = sessionID
            isPrerollRequested = false
        }
        
        if isPrerollRequested == false {
            isPrerollRequested = true
            dispatch(PlayerCore.VRMCore.adRequest(url: url, id: UUID(), type: .preroll))
        }
    }
}
