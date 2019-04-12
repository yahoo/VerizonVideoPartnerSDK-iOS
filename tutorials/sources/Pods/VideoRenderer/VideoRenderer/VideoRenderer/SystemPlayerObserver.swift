//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import AVFoundation

public final class SystemPlayerObserver: NSObject {
    public enum Event {
        case didChangeTimebaseRate(to: Float)
        case didChangeRate(to: Float)
        case didChangeExternalPlaybackStatus(to: Bool)
        case didChangeExternalPlaybackAllowance(to: Bool)
        case didChangeUrl(from: URL?, to: URL?)
        case didChangeItemStatusToUnknown
        case didChangeItemStatusToReadyToPlay
        case didChangeItemPlaybackLikelyToKeepUp(to: Bool)
        case didChangeItemPlaybackBufferEmpty(to: Bool)
        case didChangeItemStatusToFailed(error: Error)
        case didFinishPlayback(withUrl: URL)
        case didChangeLoadedTimeRanges(to: [CMTimeRange])
        case didChangeAverageVideoBitrate(to: Double)
        case didChangeItemDuration(to: CMTime)
        case didChangeAsset(AVAsset)
        case didReceivePlayerError(Error)
        case startSeek
        case stopSeek
    }
    
    private var emit: Action<Event>
    private var player: AVPlayer
    private let center = NotificationCenter.default
    
    private var accessLogToken = nil as Any?
    private var timebaseRangeToken = nil as Any?
    public init(player: AVPlayer, emit: @escaping Action<Event>) {
        self.emit = emit
        self.player = player
        super.init()
        
        player.addObserver(self,
                           forKeyPath: #keyPath(AVPlayer.currentItem),
                           options: [.initial, .new, .old],
                           context: nil)
        
        player.addObserver(self,
                           forKeyPath: #keyPath(AVPlayer.rate),
                           options: [.new],
                           context: nil)
        
        player.addObserver(self,
                           forKeyPath: #keyPath(AVPlayer.error),
                           options: [.initial, .new],
                           context: nil)
        
        player.addObserver(self,
                           forKeyPath: #keyPath(AVPlayer.isExternalPlaybackActive),
                           options: [.initial, .new],
                           context: nil)
        
        player.addObserver(self,
                           forKeyPath: #keyPath(AVPlayer.allowsExternalPlayback),
                           options: [.initial, .new],
                           context: nil)
    }
    
    @objc func didPlayToEnd(notification: NSNotification) {
        guard let item = notification.object as? AVPlayerItem else {
            return
        }
        guard let urlAsset = item.asset as? AVURLAsset else {
            fatalError("Asset is not AVURLAsset!")
        }
        
        emit(.didFinishPlayback(withUrl: urlAsset.url))
    }
    
    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { fatalError("Unexpected nil keypath!") }
        guard let change = change else { fatalError("Change should not be nil!") }
        
        func newValue<T>() -> T? {
            let change = change[NSKeyValueChangeKey.newKey]
            guard (change as? NSNull) == nil else { return nil }
            return change as? T
        }
        
        func newValueUnwrapped<T>() -> T {
            guard let newValue: T = newValue() else {
                fatalError("Unexpected nil in \(keyPath)! value!")
            }
            return newValue
        }
        
        func oldValue<T>() -> T? {
            return change[NSKeyValueChangeKey.oldKey] as? T
        }
        
        switch keyPath {
            
        case #keyPath(AVPlayer.rate):
            guard let newItem = newValue() as Float? else { return }
            emit(.didChangeRate(to: newItem))
            
        case #keyPath(AVPlayer.isExternalPlaybackActive):
            guard let newItem = newValue() as Bool? else { return }
            emit(.didChangeExternalPlaybackStatus(to: newItem))
            
        case #keyPath(AVPlayer.allowsExternalPlayback):
            guard let newItem = newValue() as Bool? else { return }
            emit(.didChangeExternalPlaybackAllowance(to: newItem))
            
        case #keyPath(AVPlayer.currentItem):
            
            let oldItem = oldValue() as AVPlayerItem?
            /* Process old item */ do {
                oldItem?.removeObserver(self,
                                        forKeyPath: #keyPath(AVPlayerItem.status))
                oldItem?.removeObserver(self,
                                        forKeyPath: #keyPath(AVPlayerItem.asset))
                oldItem?.removeObserver(self,
                                        forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
                oldItem?.removeObserver(self,
                                        forKeyPath: #keyPath(AVPlayerItem.timebase))
                oldItem?.removeObserver(self,
                                        forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp))
                oldItem?.removeObserver(self,
                                        forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty))
                if let old = oldItem {
                    center.removeObserver(self,
                                          name: .AVPlayerItemDidPlayToEndTime,
                                          object: old)
                    if let token = accessLogToken {
                        center.removeObserver(token,
                                              name: .AVPlayerItemNewAccessLogEntry,
                                              object: old)
                    }
                }
            }
            
            let newItem = newValue() as AVPlayerItem?
            /* Process new item */ do {
                newItem?.addObserver(self,
                                     forKeyPath: #keyPath(AVPlayerItem.status),
                                     options: [.initial, .new, .old],
                                     context: nil)
                newItem?.addObserver(self,
                                     forKeyPath: #keyPath(AVPlayerItem.asset),
                                     options: [.initial, .new, .old],
                                     context: nil)
                newItem?.addObserver(self,
                                     forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges),
                                     options: [.initial, .new],
                                     context: nil)
                newItem?.addObserver(self,
                                     forKeyPath: #keyPath(AVPlayerItem.timebase),
                                     options: [.initial, .new],
                                     context: nil)
                newItem?.addObserver(self,
                                     forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp),
                                     options: [.initial, .new],
                                     context: nil)
                newItem?.addObserver(self,
                                     forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty),
                                     options: [.initial, .new],
                                     context: nil)
                if let new = newItem {
                    center.addObserver(
                        self,
                        selector: #selector(SystemPlayerObserver.didPlayToEnd),
                        name: .AVPlayerItemDidPlayToEndTime,
                        object: new)
                    accessLogToken = center.addObserver(
                        forName: .AVPlayerItemNewAccessLogEntry,
                        object: nil,
                        queue: nil) { [weak self] notification in
                            guard let item = notification.object as? AVPlayerItem
                                else { return }
                            guard let log = item.accessLog() else { return }
                            guard #available(iOS 10.0, tvOS 10.0, *) else { return }
                            
                            for event in log.events {
                                self?.emit(.didChangeAverageVideoBitrate(to: event.averageVideoBitrate))
                            }
                    }
                }
            }
            
            let oldUrl: URL? = {
                guard let oldItem = oldItem else { return nil }
                guard let asset = oldItem.asset as? AVURLAsset else {
                    fatalError("Asset is not AVURLAsset!")
                }
                return asset.url
            }()
            
            let newUrl: URL? = {
                guard let newItem = newItem else { return nil }
                guard let asset = newItem.asset as? AVURLAsset else {
                    fatalError("Asset is not AVURLAsset!")
                }
                return asset.url
            }()
            
            emit(.didChangeUrl(from: oldUrl, to: newUrl))
        
        case #keyPath(AVPlayer.error):
            guard let error: Error = newValue() else { return }
            emit(.didReceivePlayerError(error))
            
        case #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp):
            guard let newItem = newValue() as Bool? else { return }
            emit(.didChangeItemPlaybackLikelyToKeepUp(to: newItem))
            
        case #keyPath(AVPlayerItem.isPlaybackBufferEmpty):
            guard let newItem = newValue() as Bool? else { return }
            emit(.didChangeItemPlaybackBufferEmpty(to: newItem))
            
        case #keyPath(AVPlayerItem.status):
            guard let newStatus = newValue().flatMap(AVPlayerItem.Status.init) else { fatalError("Unexpected nil in AVPlayerItem.status value!") }
            switch newStatus {
            case .unknown: emit(.didChangeItemStatusToUnknown)
            case .readyToPlay: emit(.didChangeItemStatusToReadyToPlay)
            case .failed:
                struct SystemPlayerFailed: Swift.Error { }
                let error = player.currentItem?.error ?? SystemPlayerFailed()
                emit(.didChangeItemStatusToFailed(error: error))
            }

        case #keyPath(AVPlayerItem.loadedTimeRanges):
            guard let timeRanges: [CMTimeRange] = newValue() else { return }
            emit(.didChangeLoadedTimeRanges(to: timeRanges))
            
        case #keyPath(AVPlayerItem.timebase):
            if let token = timebaseRangeToken {
                center.removeObserver(token)
            }
            
            guard let timebase: CMTimebase = newValue() else { return }
            
            weak var this = self
            func emitDidChangeTimebaseRate(for timebase: CMTimebase) {
                let rate = CMTimebaseGetRate(timebase)
                this?.emit(.didChangeTimebaseRate(to: Float(rate)))
            }
            emitDidChangeTimebaseRate(for: timebase)
            
            timebaseRangeToken = center.addObserver(
                forName: kCMTimebaseNotification_EffectiveRateChanged as NSNotification.Name,
                object: timebase,
                queue: nil) { notification in
                    guard let object = notification.object else { return }
                    let timebase = object as! CMTimebase
                    emitDidChangeTimebaseRate(for: timebase)
            }
            
        case #keyPath(AVPlayerItem.asset):
            guard let new: AVAsset = newValue() else { return }
            emit(.didChangeAsset(new))
            
            let status = new.statusOfValue(forKey: #keyPath(AVAsset.duration), error: nil)
            switch status {
            case .unknown, .loading, .cancelled, .failed:
                new.loadValuesAsynchronously(forKeys: [#keyPath(AVAsset.duration)],
                                             completionHandler: { [weak self] in
                                                guard case .loaded = new.statusOfValue(forKey: #keyPath(AVAsset.duration),
                                                                                       error: nil) else { return }
                                                self?.emit(.didChangeItemDuration(to: new.duration))
                })
            case .loaded:
                if new.duration != CMTime.indefinite {
                    emit(.didChangeItemDuration(to: new.duration))
                }
            }
            
        default:
            super.observeValue(
                forKeyPath: keyPath,
                of: object,
                change: change,
                context: context)
        }
    }
    
    deinit {
        player.currentItem?.removeObserver(self,
                                           forKeyPath: #keyPath(AVPlayerItem.status))
        player.currentItem?.removeObserver(self,
                                           forKeyPath: #keyPath(AVPlayerItem.asset))
        player.currentItem?.removeObserver(self,
                                           forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
        player.currentItem?.removeObserver(self,
                                           forKeyPath: #keyPath(AVPlayerItem.timebase))
        player.currentItem?.removeObserver(self,
                                           forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp))
        player.currentItem?.removeObserver(self,
                                           forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty))
        player.removeObserver(self,
                              forKeyPath: #keyPath(AVPlayer.currentItem))
        player.removeObserver(self,
                              forKeyPath: #keyPath(AVPlayer.rate))
        player.removeObserver(self,
                              forKeyPath: #keyPath(AVPlayer.error))
        player.removeObserver(self,
                              forKeyPath: #keyPath(AVPlayer.isExternalPlaybackActive))
        player.removeObserver(self,
                              forKeyPath: #keyPath(AVPlayer.allowsExternalPlayback),
                              context: nil)
        center.removeObserver(self,
                              name: .AVPlayerItemDidPlayToEndTime,
                              object: player.currentItem)
        if let token = accessLogToken {
            center.removeObserver(token,
                                  name: .AVPlayerItemNewAccessLogEntry,
                                  object: player.currentItem)
        }
        
        if let token = timebaseRangeToken {
            center.removeObserver(token,
                                  name: kCMTimebaseNotification_EffectiveRateChanged as NSNotification.Name,
                                  object: player.currentItem)
        }
    }
}
