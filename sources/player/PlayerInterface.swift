//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import CoreMedia
import PlayerCore

extension Player {
    
    /// Should be called when duration of current video is known.
    /// Can be called more than one time during single video playback. (AVPlayer details)
    /// Usually, this event is expected from AVFoundation layer.
    public func update(duration: CMTime) {
        dispatch(action: PlayerCore.updateContentDuration(duration: duration))
    }
    
    /// Should be called as a part of avplayer-model sync process.
    /// Usually no need to call it by hands.
    public func update(currentTime time: CMTime) {
        dispatch(action: PlayerCore.updateContentCurrentTime(time: time, date: Date()))
    }
    
    /// This event is expected from AVFoundation layer.
    /// Playback value indicates is playback active currently or not.
    public func update(playback: Bool) {
        dispatch(action: PlayerCore.updateContentPlaybackRate(isPlaying: playback), type: .sync)
    }
    
    func update(bufferedTime time: CMTime) {
        dispatch(action: PlayerCore.updateContentBufferedTime(time: time))
    }
    
    /// Mark that current video is finished.
    /// This event is expected from AVFoundation layer.
    public func endPlayback() {
        
        dispatch(action: PlayerCore.contentEndPlayback(currentIdx: store.state.value.playlist.currentIndex,
                                                       count: model.playlist.count,
                                                       prerolls: model.prerolls,
                                                       midrolls: model.midrolls))
    }
    
    /// Used **ONLY** for metrics API calls.
    /// Call when your player view have changed its size.
    /// It is important to send update this data as soon as possible.
    public func update(playerDimensions size: CGSize?) {
        guard props.dimensions != size else { return }
        guard props.playbackItem?.content.airPlay != .active else { return }
        guard props.playbackItem?.ad.airPlay != .active else { return }
        guard props.playbackItem?.content.pictureInPictureMode != .active else { return }
        guard props.playbackItem?.ad.pictureInPictureMode != .active else { return }
        dispatch(action: PlayerCore.updateViewportDimensions(
            currentSize: props.dimensions,
            newSize: size))
    }
    
    func contentReady() {
        dispatch(action: PlayerCore.contentPlaybackIsReady())
    }
    
    func contentErrored(with error: NSError) {
        dispatch(action: PlayerCore.contentPlaybackIsFailed(error: error))
    }
}

/// Playback control events. Usually they called from Controls view controller.
extension Player {
    
    /// This event is expected from user controls
    public func play() {
        dispatch(action: PlayerCore.play(), type: .sync)
    }
    
    /// This event is expected from user controls
    public func pause() {
        dispatch(action: PlayerCore.pause(), type: .sync)
    }
    
    /// This event is expected from user controls
    /// Video will be replayed from start.
    public func replay() {
        dispatch(action: PlayerCore.replay(currentIndex: store.state.value.playlist.currentIndex,
                                           prerolls: model.prerolls,
                                           midrolls: model.midrolls))
    }
}

/// Seek related events. Usually they called from seeker implementation.
extension Player {
    
    /// Call when position of video will be changed by user.
    ///
    /// - parameter progress: `Player.TimeInfo.Progress` value from 0 to 1.
    public func seek(toProgress progress: Progress) {
        
        dispatch(action: PlayerCore.seekToProgress(progress: progress,
                                                   duration: store.state.value.duration.content),
                 type: .sync)
    }
    
    /// Call seek to specific position.
    ///
    /// - parameter seconds: Number of seconds.
    public func seek(to seconds: Int) {
        guard seconds > 0 else { return }
        
        dispatch(action: PlayerCore.seekToSeconds(seconds: Double(seconds),
                                                  timescale: store.state.value.currentTime.content?.time.timescale ?? 600,
                                                  duration: store.state.value.duration.content),
                 type: .sync)
    }
    /// Call seek to specific CMTime.
    ///
    /// - parameter time: CMTime representation of time position.
    public func seek(to time: CMTime) {
        dispatch(action: PlayerCore.seekToTime(time: time,
                                               in: store.state.value.duration.content),
                 type: .sync)
    }
    
    /// Call when start a dragging seek
    /// This call is expected from seeker control.
    ///
    /// - parameter progress: `Player.TimeInfo.Progress` value from 0 to 1.
    public func startInteractiveSeek(fromProgress progress: Progress) {
        dispatch(action: PlayerCore.startInteractiveSeeking(progress: progress,
                                                            duration: store.state.value.duration.content),
                 type: .sync)
    }
    
    /// Call when a dragg;ing seek is stopped
    /// This call is expected from seeker control.
    ///
    /// - parameter progress: `Player.TimeInfo.Progress` value from 0 to 1.
    public func stopInteractiveSeek(withProgress progress: Progress) {
        dispatch(action: PlayerCore.stopInteractiveSeeking(progress: progress,
                                                           duration: store.state.value.duration.content),
                 type: .sync)
    }
    
    /// Call before AVPlayer.seek(time:, toleranceBefore:, toleranceAfter:, completionHandler:)
    public func didStartSeek() {
        dispatch(action: PlayerCore.didStartSeek(), type: .sync)
    }
    
    /// Call when AVPlayer.seek(time:, toleranceBefore:, toleranceAfter:, completionHandler:) is completed
    public func didStopSeek() {
        dispatch(action: PlayerCore.didStopSeek(), type: .sync)
    }
}

/// Playlist related events. Usually they called from Controls view controller.
extension Player {
    /// Call when you need to select next video in playlist.
    /// If this event will be fired on first video - nothing will happen.
    public func nextVideo() {
        dispatch(action: PlayerCore.next(currentIdx: store.state.value.playlist.currentIndex,
                                         prerolls: model.prerolls,
                                         midrolls: model.midrolls))
    }
    
    /// Call when you need to select prev video in playlist.
    /// If this event will be fired on first video - nothing will happen.
    public func prevVideo() {
        dispatch(action: PlayerCore.prev(currentIdx: store.state.value.playlist.currentIndex,
                                         prerolls: model.prerolls,
                                         midrolls: model.midrolls))
    }
    
    /// Select video at specified index. Playback will depend on 'autoplay' parameter.
    /// If playlist current index is equal to provided index - nothing will happen.
    /// If playlist count is less than provided index - nothing will happen.
    /// If picture in picture mode active - nothing will happen.
    public func selectVideo(atIndex index: Int) {
        guard let select = try? VideoSelector(index: index,
                                              currentIndex: props.playlist.currentIndex,
                                              playlistCount: model.playlist.count) else { return }
        dispatch(action: PlayerCore.selectVideoAtIndex(idx: select.index,
                                                       prerolls: model.prerolls,
                                                       midrolls: model.midrolls))
    }
}

extension Player {
    /// Should be called when duration of current video is known.
    /// Can be called more than one time during single video playback. (AVPlayer details)
    /// Usually, this event is expected from AVFoundation layer.
    func adUpdate(duration: CMTime) {
        let vastAdProgress = store.state.value.vrmFinalResult.successResult?.inlineVAST.adProgress ?? []
        dispatch(action: PlayerCore.updateAdDuration(duration: duration, vastAdProgress: vastAdProgress))
    }
    
    /// Should be called as a part of avplayer-model sync process.
    /// Usually no need to call it by hands.
    func adUpdate(currentTime time: CMTime) {
        dispatch(action: PlayerCore.updateAdCurrentTime(time: time),
                 type: .sync)
    }
    
    /// This event is expected from AVFoundation layer.
    /// Playback value indicates is playback active currently or not.
    func adUpdate(playback: Bool) {
        dispatch(action: PlayerCore.updateAdPlaybackRate(isPlaying: playback), type: .sync)
    }
    
    func adUpdate(bufferedTime time: CMTime) {
        dispatch(action: PlayerCore.updateAdBufferedTime(time: time))
    }
    
    /// Mark that current video is finished.
    /// This event is expected from AVFoundation layer.
    func adEndPlayback() {
        dispatch(action: PlayerCore.adEndPlayback())
    }
    
    func playAd(model: PlayerCore.Ad.VASTModel) {
        dispatch(action: PlayerCore.playAd(model: model, id: UUID()))
    }
    
    func adReady() {
        dispatch(action: PlayerCore.adPlaybackIsReady())
    }
    
    func adErrored(with error: NSError) {
        dispatch(action: PlayerCore.adPlaybackIsFailed(error: error))
    }
    
    func dropAd(id: UUID) {
        dispatch(action: PlayerCore.dropAd(id: id))
    }
    func skipAd() {
        dispatch(action: PlayerCore.skipAd())
    }
}

extension Player {
    func contentExternalPlaybackStatusChanged(status: Bool) {
        dispatch(action: PlayerCore.update(externalPlaybackStatus: status))
    }
    
    func adExternalPlaybackStatusChanged(status: Bool) {
        dispatch(action: PlayerCore.update(externalPlaybackStatus: status))
    }
    
    func contentExternalPlaybackAllowanceChanged(status: Bool) {
        dispatch(action: PlayerCore.update(externalPlaybackAllowance: status))
    }
    
    func adExternalPlaybackAllowanceChanged(status: Bool) {
        dispatch(action: PlayerCore.update(externalPlaybackAllowance: status))
    }
}

extension Player {
    func activateClickThrough() {
        dispatch(action: PlayerCore.requestClickthroughAdPresentation())
    }
    
    func deactivateClickThrough(isAdVPAID: Bool = false) {
        dispatch(action: PlayerCore.didHideAdClickthrough(isAdVPAID: isAdVPAID))
    }
}

extension Player {
    /// Mute player.
    public func mute() {
        dispatch(action: PlayerCore.mute())
    }
    
    /// Unmute player.
    public func unmute() {
        dispatch(action: PlayerCore.unmute())
    }
}

extension Player {
    /// Update player angles
    public func updateCameraAngles(_ vertical: Float, _ horizontal: Float) {
        dispatch(action: PlayerCore.updateCameraAngles(horizontal: horizontal, vertical: vertical))
    }
}

extension Player {
    public func togglePictureInPictureMode() {
        dispatch(action: PlayerCore.pictureInPictureToggle())
    }
    
    public func update(pictureInPicturePossible isPossible: Bool) {
        dispatch(action: PlayerCore.pictureInPictureStatusUpdate(isPossible: isPossible))
    }
}

extension Player {
    public func update(averageBitrate: Double) {
        dispatch(action: PlayerCore.updateContent(averageBitrate: averageBitrate))
    }
    
    public func adUpdate(averageBitrate: Double) {
        dispatch(action: PlayerCore.updateAd(averageBitrate: averageBitrate))
    }
}

extension Player {
    func update(availableAudibleOptions options: [MediaOptions.Option]) {
        dispatch(action: PlayerCore.update(availableAudibleOptions: options))
    }
    
    func update(availableLegibleOptions options: [MediaOptions.Option]) {
        dispatch(action: PlayerCore.update(availableLegibleOptions: options))
    }
    
    public func selectAudible(option: MediaOptions.Option?) {
        dispatch(action: PlayerCore.select(audibleOption: option))
    }
    
    public func selectLegible(option: MediaOptions.Option?) {
        dispatch(action: PlayerCore.select(legibleOption: option))
    }
    
    public func didStartMediaOptionDiscovery() { }
}

extension Player {
    func contentDidPlay() {
        dispatch(action: PlayerCore.contentDidPlay())
    }
    
    func contentDidPause() {
        dispatch(action: PlayerCore.contentDidPause(
            seekInProgress: store.state.value.interactiveSeeking.isSeekingInProgress))
    }
    
    func adDidPlay() {
        dispatch(action: PlayerCore.adDidPlay())
    }
    
    func adDidPause() {
        dispatch(action: PlayerCore.adDidPause())
    }
}

extension Player {
    func toggleContentFullScreenMode() {
        dispatch(action: PlayerCore.contentFullScreenToggle())
    }
}

extension Player {
    func updateVPAIDAdState(with event: VPAIDEvents) {
        dispatch(action: PlayerCore.createAction(from: event), type: .sync)
    }
}
extension Player {
    func serviceScriptSuccessfullyRecieved() {
        dispatch(action: PlayerCore.recievedOMScript())
    }
    func serviceScriptLoadingFailed(error: Error) {
        dispatch(action: PlayerCore.failedOMScriptLoading(with: error))
    }
}
extension Player {
    func updateContentPlaybackBufferingActive() {
        dispatch(action: PlayerCore.updateContentPlaybackBufferingActive())
    }
    
    func updateAdPlaybackBufferingActive() {
        dispatch(action: PlayerCore.updateAdPlaybackBufferingActive())
    }
    
    func updateContentPlaybackBufferingInactive() {
        dispatch(action: PlayerCore.updateContentPlaybackBufferingInactive())
    }
    
    func updateAdPlaybackBufferingInactive() {
        dispatch(action: PlayerCore.updateAdPlaybackBufferingInactive())
    }
}
