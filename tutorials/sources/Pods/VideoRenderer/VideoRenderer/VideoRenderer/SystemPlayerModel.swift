//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import AVFoundation
import CoreMedia

class KVOTracker: NSObject {
    var keyPaths: [String] { return [] }
    
    override init() {
        super.init()
        
        for path in keyPaths {
            addObserver(self, forKeyPath: path, options: [.initial, .new], context: nil)
        }
    }
    
    deinit {
        for path in keyPaths {
            removeObserver(self, forKeyPath: path)
        }
    }
}

enum SystemPlayer {}

extension SystemPlayer {
    
    class Tracker: KVOTracker {
        override var keyPaths: [String] {
            return [
                "currentTime",
                "player.currentItem",
                "player.rate",
                "player.status",
                "player.error",
                "player.currentItem.status",
                "player.currentItem.error",
                "player.currentItem.duration",
                "player.currentItem.presentationSize",
                "player.currentItem.loadedTimeRanges",
                "player.currentItem.playbackLikelyToKeepUp",
                "player.currentItem.playbackBufferFull",
                "player.currentItem.playbackBufferEmpty"
            ]
        }
        
        
        var timeObserver: Any!
        @objc var currentTime: AnyObject!
        
        @objc var currentItem: AVPlayerItem? {
            willSet {
                guard let item = currentItem else { return }
                
                func removeObserver(name: String) {
                    NotificationCenter.default.removeObserver(
                        self, name: Notification.Name(rawValue: name), object: item)
                }
                
                removeObserver(name: Notification.Name.AVPlayerItemTimeJumped.rawValue)
                removeObserver(name: Notification.Name.AVPlayerItemDidPlayToEndTime.rawValue)
                removeObserver(name: Notification.Name.AVPlayerItemFailedToPlayToEndTime.rawValue)
                removeObserver(name: Notification.Name.AVPlayerItemPlaybackStalled.rawValue)
                removeObserver(name: Notification.Name.AVPlayerItemNewAccessLogEntry.rawValue)
                removeObserver(name: Notification.Name.AVPlayerItemNewErrorLogEntry.rawValue)
            }
            
            didSet {
                guard let item = currentItem else { return }
                
                func addObserver(withName name: String) {
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(handleNotification),
                        name: Notification.Name(rawValue: name),
                        object: item)
                }
                
                addObserver(withName: Notification.Name.AVPlayerItemTimeJumped.rawValue)
                addObserver(withName: Notification.Name.AVPlayerItemDidPlayToEndTime.rawValue)
                addObserver(withName: Notification.Name.AVPlayerItemFailedToPlayToEndTime.rawValue)
                addObserver(withName: Notification.Name.AVPlayerItemPlaybackStalled.rawValue)
                addObserver(withName: Notification.Name.AVPlayerItemNewAccessLogEntry.rawValue)
                addObserver(withName: Notification.Name.AVPlayerItemNewErrorLogEntry.rawValue)
            }
        }
        
        let player: AVPlayer
        init(player: AVPlayer) {
            self.player = player
            super.init()
            
            let interval = CMTime(seconds: 0.5, preferredTimescale: 1000)
            timeObserver = player.addPeriodicTimeObserver(
                forInterval: interval,
                queue: DispatchQueue.main) { [weak self] time in
                    self?.currentTime = NSValue(time: time)
            }
        }
        
        deinit {
            player.removeTimeObserver(timeObserver)
        }
        
        func print(event: String) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss,mmm"
            Swift.print("\(self.player): \(formatter.string(from: Date())) \(event)")
        }
        
        @objc func handleNotification(notification: NSNotification) {
            self.print(event: "\(notification.name): \(String(describing: notification.userInfo))")
        }
        //swiftlint:disable cyclomatic_complexity
        override func observeValue(forKeyPath keyPath: String?,
                                   of object: Any?,
                                   change: [NSKeyValueChangeKey : Any]?,
                                   context: UnsafeMutableRawPointer?) {
            guard let keyPath = keyPath else { fatalError() }
            guard let change = change else { fatalError() }
            guard var new = change[NSKeyValueChangeKey.newKey] as Any? else { fatalError() }
            
            switch keyPath {
            case "player.status" where new is Int:
                guard let value = new as? Int else { fatalError() }
                guard let status = AVPlayer.Status(rawValue: value) else { fatalError() }
                new = status
                
            case "player.currentItem.status" where new is Int:
                guard let value = new as? Int else { fatalError() }
                guard let status = AVPlayerItem.Status(rawValue: value) else { fatalError() }
                new = status
                
            case "currentTime" where new is NSValue,
                 "player.currentItem.duration" where new is NSValue:
                guard let value = new as? NSValue else { fatalError() }
                new = value.timeValue
                
            case "player.currentItem":
                currentItem = new as? AVPlayerItem
                
            default: break }
            
            print(event: "\(keyPath): \(new)")
        }
        //swiftlint:enable cyclomatic_complexity
    }
}

extension AVPlayer.Status: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .unknown: return ".unknown"
        case .readyToPlay: return ".readyToPlay"
        case .failed: return ".failed"
        }
    }
}

extension AVPlayerItem.Status: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .unknown: return ".unknown"
        case .readyToPlay: return ".readyToPlay"
        case .failed: return ".failed"
        }
    }
}

extension CMTime: CustomDebugStringConvertible {
    public var debugDescription: String {
        if self.isIndefinite { return "Indefinite" }
        if self.isNegativeInfinity { return "-Inf" }
        if self.isPositiveInfinity { return "+Inf" }
        if !self.isValid { return "Invalid" }
        
        guard self.isValid else { fatalError() }
        
        return "\(self.seconds) (\(self.value)/\(self.timescale))"
    }
}
