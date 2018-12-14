//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    final class VideoImpression {

        struct Context {
            let sessionId: UUID
            let dimensions: CGSize?
            let isPlaybackItemAvaliable: Bool
        }
        
        struct Result {
            let dimensions: CGSize
        }
        
        private var sessionId = UUID()
        
        func process(_ props: Player.Properties) -> Result? {
            let context = Context(sessionId: props.session.playback.id,
                                  dimensions: props.dimensions,
                                  isPlaybackItemAvaliable: props.playbackItem != nil)
            return process(context: context)
        }
        
        func process(context: Context) -> Result? {
            guard self.sessionId != context.sessionId,
                  let dimensions = context.dimensions,
                  context.isPlaybackItemAvaliable else { return nil }
            self.sessionId = context.sessionId
            return Result(dimensions: dimensions)
        }
    }
}
