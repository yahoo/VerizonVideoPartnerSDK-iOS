//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import VideoRenderer
import CoreMedia

extension SystemPlayerViewController.Context {
    final class ReplayDetector {
        private(set) var endPlaybackDetected = false
        
        private let onReplay: Action<Void>
        init(onReplay: @escaping Action<Void>) {
            self.onReplay = onReplay
        }
        struct Props {
            var event: SystemPlayerObserver.Event?
            var time = CMTime.zero
        }
        
        var props = Props() {
            didSet(old) {
                guard let event = props.event else { return }
                
                if case .didFinishPlayback = event { endPlaybackDetected = true }
                if old.time != props.time, props.time.seconds != 0.0 { endPlaybackDetected = false }
                
                guard
                    endPlaybackDetected,
                    case .didChangeTimebaseRate(let newRate) = event,
                    newRate == 1.0 else { return }
                
                onReplay(())
                
                endPlaybackDetected = false
            }
        }
    }
}
