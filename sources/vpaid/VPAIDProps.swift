//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreMedia

public struct VPAIDProps {
    public struct PlaybackProps: Codable {
        let url: String
        let adParameters: String?
        let rate: Float
        let isMuted: Bool
        let isSessionCompleted: Bool
    }
    
    let documentUrl: URL
    let playbackProps: PlaybackProps
}
