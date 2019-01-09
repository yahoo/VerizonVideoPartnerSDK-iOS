//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import PlayerControls
import PlayerCore
import SafariServices

extension ContentControlsViewController {
    //swiftlint:disable cyclomatic_complexity
    //swiftlint:disable function_body_length
    static func connect(player: Player,
                        toggleSettings: @escaping () -> Void,
                        showSafari: @escaping (URL, SFSafariViewControllerDelegate) -> Void) -> (Player.Properties) -> Props {
        return { props in
            func playerProps() -> Props.Player {
                func playlist() -> Props.Playlist? {
                    guard props.playlist.count > 1 else { return nil }
                    
                    func next() -> CommandWith<Void>? {
                        guard props.playlist.hasNextVideo else { return nil }
                        switch props.item {
                        case .available(let item):
                            return item.content.isSeeking ? nil : CommandWith(action: player.nextVideo)
                        case .unavailable:
                            return CommandWith(action: player.nextVideo)
                        }
                    }
                    
                    func prev() -> CommandWith<Void>? {
                        guard props.playlist.hasPrevVideo else { return nil }
                        switch props.item {
                        case .available(let item):
                            return item.content.isSeeking ? nil : CommandWith(action: player.prevVideo)
                        case .unavailable:
                            return CommandWith(action: player.prevVideo)
                        }
                    }
                    
                    return Props.Playlist {
                        $0.next = next()
                        $0.prev = prev()
                    }
                }
                
                func controls(for item: Player.Properties.PlaybackItem.Available) -> Props.Controls {
                    let hasAdToLoad = item.hasActiveAds && !item.isAdPlaying
                    let thumbnailPlay = props.isPlaybackInitiated && hasAdToLoad
                    let thumbnailVisible = !props.isPlaybackInitiated
                        || (hasAdToLoad && !props.isAutoplayEnabled)
                    
                    func title() -> String {
                        return thumbnailVisible ? "" : item.title
                    }
                    
                    func loading() -> Bool {
                        guard item.content.status.isReady || item.content.status.isUndefined else { return false }
                        return item.content.isBuffering
                            || item.content.time.isUnknown
                            || thumbnailPlay
                    }
                    
                    func playbackAction() -> Props.Playback {
                        guard item.content.status.isReady || item.content.status.isUndefined else { return .none }
                        if item.content.isSeeking || thumbnailPlay { return .none }
                        if item.isReplayable { return .replay(CommandWith(action: player.replay)) }
                        if item.content.isPaused { return .play(CommandWith(action: player.play)) }
                        if item.content.isPlaying { return .pause(CommandWith(action: player.pause)) }
                        
                        return .none
                    }
                    
                    func isLive() -> Props.Live {
                        return Props.Live {
                            $0.isHidden = !item.content.time.isLive
                            $0.dotColor = nil
                        }
                    }
                    
                    func seekbar() -> Props.Seekbar? {
                        guard !thumbnailVisible else { return nil }
                        guard item.content.status.isReady || item.content.status.isUndefined else { return nil }
                        guard let time = item.content.time.static else { return nil }
                        
                        func duration() -> Props.Seconds {
                            return .init(time.duration)
                        }
                        
                        func currentTime() -> Props.Seconds {
                            return .init(time.current ?? 0)
                        }
                        
                        func seeker() -> Props.Seeker {
                            func seekTo() -> CommandWith<Props.Seconds>? {
                                return item.content.isSeeking ? nil : CommandWith(action: player.seek(to:))
                            }
                            
                            func state() -> Props.State {
                                return .init {
                                    $0.start = CommandWith(action: player.startInteractiveSeek).map(block: Progress.init)
                                    $0.update = CommandWith(action: player.seek).map(block: Progress.init)
                                    $0.stop = CommandWith(action: player.stopInteractiveSeek).map(block: Progress.init)
                                }
                            }
                            
                            func cuePoints() -> [Props.Progress] {
                                return item.midrolls
                                    .map { Props.Progress(CGFloat($0.cuePoint) / CGFloat(time.duration))}
                            }
                            
                            return .init {
                                $0.cuePoints = cuePoints()
                                $0.seekTo = seekTo()
                                $0.state = state()
                            }
                        }
                        
                        return Props.Seekbar {
                            $0.duration = duration()
                            $0.currentTime = currentTime()
                            $0.progress = .init(time.progress)
                            $0.buffered = .init(item.content.bufferInfo.progress)
                            $0.seeker = seeker()
                        }
                    }
                    
                    func camera() -> Props.Camera? {
                        guard let stateAngles = item.videoAngles else { return nil }
                        let angles = Props.Angles {
                            $0.horizontal = stateAngles.horizontal
                            $0.vertical = stateAngles.vertical
                        }
                        
                        func moveTo(angles: Props.Angles) {
                            player.updateCameraAngles(angles.vertical, angles.horizontal)
                        }
                        
                        return Props.Camera {
                            $0.angles = angles
                            $0.moveTo = CommandWith(action: moveTo)
                        }
                    }
                    
                    func thumbnail() -> Props.Thumbnail? {
                        guard thumbnailVisible else { return nil }
                        guard let dimensions = props.dimensions else { return nil }
                        guard let thumbnail = item.model.thumbnail else { return nil }
                        
                        return .url(thumbnail[dimensions])
                    }
                    
                    func error() -> Props.Error? {
                        guard case .failed(let error) = item.content.status else { return nil }
                        return Props.Error {
                            $0.message = error.localizedDescription
                            $0.retryAction = CommandWith(action: player.replay)
                        }
                    }
                    
                    func pictureInPictureControl() -> Props.PictureInPictureControl {
                        guard !thumbnailVisible else { return .unsupported }
                        switch item.content.pictureInPictureMode {
                        case .possible:
                            return .possible(CommandWith(action: player.togglePictureInPictureMode))
                        case .impossible:
                            return .impossible
                        case .unsupported:
                            return .unsupported
                        case .active:
                            fatalError("Content controls for picture in picture active state does not supported")
                        }
                    }
                    
                    func audible() -> Props.MediaGroupControl? {
                        let audible = item.content.audible
                        guard audible.options.count > 0 else { return nil }
                        return Props.MediaGroupControl(
                            options: audible.options.map { option in
                                return Props.Option(
                                    name: option.displayName,
                                    selected: option.selected,
                                    select: CommandWith { player.selectAudible(option: .init(availableOption: option)) })})
                    }
                    
                    func legible() -> Props.MediaGroupControl? {
                        switch item.content.legible {
                        case .`internal`(let `internal`):
                            guard let `internal` = `internal` else { return nil }
                            guard `internal`.options.count > 0 else { return nil }
                            return Props.MediaGroupControl(
                                options: `internal`.options.map { option in
                                    return Props.Option(
                                        name: option.displayName,
                                        selected: option.selected,
                                        select: CommandWith { player.selectLegible(option: .init(availableOption: option)) })})
                        case .external: return nil
                        }
                    }
                    
                    let settings: Props.Settings = {
                        let hasAudible = item.content.audible.options.count > 1
                        let hasLegible: Bool = {
                            switch item.content.legible {
                            case .external: return true
                            case .`internal`(let group):
                                guard let group = group else { return false }
                                return group.options.count > 1
                            }
                        }()
                        guard hasLegible || hasAudible else { return .disabled }
                        return .enabled(CommandWith(action: toggleSettings))
                    }()
                    
                    let airplay: Props.AirPlay = {
                        switch item.content.airPlay {
                        case .inactive:
                            return .enabled
                        case .restricted, .disabled:
                            return .hidden
                        case .active:
                            return .active
                        }
                    }()
                    
                    func brandedContent() -> Props.BrandedContent? {
                        guard let brandedContent = props.playbackItem?.model.brandedContent else { return nil }
                        
                        func action() -> CommandWith<SFSafariViewControllerDelegate>? {
                                if item.isClickThroughToggled {
                                    return CommandWith { _ in
                                        player.deactivateClickThrough()
                                    }
                                } else {
                                    guard let url = brandedContent.clickUrl else { return nil }
                                    return CommandWith { delegate in
                                        player.activateClickThrough()
                                        showSafari(url, delegate)
                                    }
                            }
                        }
                        
                        return Props.BrandedContent {
                            $0.advertisementText = brandedContent.advertisementText
                            $0.action = action()
                        }
                    }
                    
                    let contentFullScreen = CommandWith(action: player.toggleContentFullScreenMode)
                    
                    return Props.Controls {
                        $0.title = title()
                        $0.animationsEnabled = item.content.controlsAnimationSupport
                        $0.loading = loading()
                        $0.playbackAction = playbackAction()
                        $0.live = isLive()
                        $0.seekbar = seekbar()
                        $0.camera = camera()
                        $0.thumbnail = thumbnail()
                        $0.sideBarViewHidden = thumbnailVisible
                        $0.error = error()
                        $0.pictureInPictureControl = pictureInPictureControl()
                        $0.audible = audible()
                        $0.legible = legible()
                        $0.settings = settings
                        $0.airplay = airplay
                        $0.contentFullScreen = contentFullScreen
                        $0.brandedContent = brandedContent()
                    }
                }
                
                func item() -> Props.Item {
                    switch props.item {
                    case .available(let item):
                        return Props.Item.playable(controls(for: item))
                    case .unavailable(let errorItem):
                        return Props.Item.nonplayable(errorItem.reason)
                    }
                }
                
                return .init {
                    $0.playlist = playlist()
                    $0.item = item()
                }
            }
            
            let pipModeActive = props.playbackItem?.content.pictureInPictureMode == .active
            return pipModeActive ? .pictureInPicture : .player(playerProps())
        }
    }
}

extension Progress {
    init(_ controlsProgress: ContentControlsViewController.Props.Progress) {
        self.init(controlsProgress.value)
    }
}

extension ContentControlsViewController.Props.Progress {
    init(_ coreProgress: Progress) {
        self.init(NativeValue(coreProgress.value))
    }
}

extension MediaOptions.Option {
    init(availableOption: Player.Properties.PlaybackItem.Video.MediaGroup.Option) {
        self.init(uuid: availableOption.id, displayName: availableOption.displayName)
    }
}
