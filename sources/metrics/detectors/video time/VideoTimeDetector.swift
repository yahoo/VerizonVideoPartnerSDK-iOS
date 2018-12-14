//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    final class VideoTime {
        
        // This struct stores all data that need to be returned when event occurs
        struct Payload {
            let index: Int
            let progress: Progress?
            let session: UUID
            let playTime: TimeInterval
        }
        
        private var currentSessionID: UUID?
        private var sessionWasCompleted: Bool = false
        private var streamWasPlayed: Bool = false
        private var storedPayload: Payload?
        
        func process(sessionID: UUID,
                     isCompleted: Bool,
                     isStreamPlaying: Bool,
                     payload: Payload) -> Payload? {
            
            let isSessionBecomeCompleted = isCompleted && !sessionWasCompleted
            let isSessionChanged = sessionID != currentSessionID
            
            defer {
                currentSessionID = sessionID
                sessionWasCompleted = isCompleted
                
                if isSessionChanged { streamWasPlayed = false }
                streamWasPlayed =  streamWasPlayed || isStreamPlaying
                
                storedPayload = payload
            }
            
            if isSessionBecomeCompleted && streamWasPlayed { return storedPayload }
            if isSessionChanged && streamWasPlayed { return storedPayload }
            
            return nil
        }
    }
}

extension Detectors.VideoTime {
    func process(props: Player.Properties) -> Payload? {
        guard let item = props.playbackItem else { return nil }
        
        let payload = Payload(
            index: props.playlist.currentIndex,
            progress: item.content.time.static?.progress,
            session: props.session.playback.id,
            playTime: props.session.playback.duration
        )
        
        return process(sessionID: props.session.playback.id,
                       isCompleted: props.isSessionCompleted,
                       isStreamPlaying: item.content.isStreamPlaying,
                       payload: payload)
    }
}
