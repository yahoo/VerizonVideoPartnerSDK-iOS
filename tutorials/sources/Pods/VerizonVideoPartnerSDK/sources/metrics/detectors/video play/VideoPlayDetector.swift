//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    final class VideoPlay {
        struct Result { let size: CGSize }
        
        private var sessionId: UUID
        init(sessionID: UUID = UUID()) {
            self.sessionId = sessionID
        }
        
        func process(dimensions: CGSize?,
                     isStreamPlaying: Bool,
                     sessionID: UUID) -> Result? {
            guard let dimensions = dimensions, isStreamPlaying else { return nil }
            guard self.sessionId != sessionID else { return nil }
            
            self.sessionId = sessionID
            
            return Result(size: dimensions)
        }
        
        func process(_ props: Player.Properties) -> Result? {
            guard let item = props.playbackItem else { return nil }
            return process(dimensions: props.dimensions,
                           isStreamPlaying: item.content.isStreamPlaying,
                           sessionID: props.session.playback.id)
        }
    }
}
