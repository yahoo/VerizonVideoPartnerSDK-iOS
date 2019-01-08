//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import CoreMedia
import PlayerControls
import VideoRenderer
import SafariServices
import PlayerCore

extension PlayerViewController {
    //swiftlint:disable cyclomatic_complexity
    //swiftlint:disable function_body_length.
    static func bind(player: Player,
                     toggleSettings: @escaping () -> Void,
                     showSafari: @escaping (URL, SFSafariViewControllerDelegate) -> Void,
                     adViewAction: @escaping () -> UIView?,
                     callback: @escaping (Props) -> ()) -> Player.PropsObserverDispose {
        let contextPresenter = VideoContextPresenter()
        let contentControlsConnector = ContentControlsViewController.connect(
            player: player,
            toggleSettings: toggleSettings,
            showSafari: showSafari)
        
        let clickthroughDetector = AdClickthroughWorker(showSafari: showSafari) {
            player.deactivateClickThrough(isAdVPAID: $0)
        }
        
        let dispatcher: (PlayerCore.Action) -> Void = { [weak player] in player?.store.dispatch(action: $0) }
        
        let openMeasurementAdSessionController = OpenMeasurement.AdSessionController(
            adViewAction: adViewAction,
            createOMContext: OpenMeasurement.createOpenMeasurementContext,
            dispatcher: dispatcher)
        
        _ = player.store.addObserver(with: player.model,
                                     mode: .everyUpdate) { state,_ in
                                        openMeasurementAdSessionController.process(with: state.openMeasurement)
        }
        
        OpenMeasurement.fetchOMServiceScript(url: player.model.omSettings.serviceScriptURL)
            .onSuccess {
                openMeasurementAdSessionController.serviceScript = $0
                player.serviceScriptSuccessfullyRecieved()
            }
            .onError(call: player.serviceScriptLoadingFailed)
        
        func contentRendererDispatch(event: Renderer.Event) {
            switch event {
            case .didChangeRate(let rate): rate == 1.0 ? player.contentDidPlay() : player.contentDidPause()
            case .didChangeTimebaseRate(let rate): player.update(playback: rate == 1.0)
            case .playbackReady: player.contentReady()
            case .playbackFailed(let error): player.contentErrored(with: error as NSError)
            case .playbackFinished: player.endPlayback()
            case .durationReceived(let duration): player.update(duration: duration)
            case .currentTimeUpdated(let time): player.update(currentTime: time)
            case .bufferedTimeUpdated(let time): player.update(bufferedTime: time)
            case .pictureInPictureStopped: player.togglePictureInPictureMode()
            case .pictureInPictureIsPossible(let possible): player.update(pictureInPicturePossible: possible)
            case .externalPlaybackAllowance(let status):
                player.contentExternalPlaybackAllowanceChanged(status: status)
            case .externalPlaybackPossible(let status):
                player.contentExternalPlaybackStatusChanged(status: status)
            case .averageVideoBitrateUpdated(let new): player.update(averageBitrate: new)
            case .updateAudibleOptions(let options):
                player.update(availableAudibleOptions: options.unselectedOptions.map(MediaOptions.Option.init))
                player.selectAudible(option: options.selectedOption.map(MediaOptions.Option.init))
            case .updateLegibleOptions(let options):
                player.update(availableLegibleOptions: options.unselectedOptions.map(MediaOptions.Option.init))
                player.selectLegible(option: options.selectedOption.map(MediaOptions.Option.init))
            case .startDiscoveringMediaOptions: player.didStartMediaOptionDiscovery()
            case .didStartSeek: player.didStartSeek()
            case .didStopSeek: player.didStopSeek()
            case .contentFullScreenToggled: player.toggleContentFullScreenMode()
            case .playbackLikelyToKeepUp(let isPlayable):
                guard isPlayable else { break }
                player.updateContentPlaybackBufferingInactive()
            case .playbackBufferEmpty(let isEmpty):
                guard isEmpty else { break }
                player.updateContentPlaybackBufferingActive()
            }
        }
        
        func adRendererDispatch(event: Renderer.Event) {
            switch event {
            case .didChangeRate(let rate): rate == 1.0 ? player.adDidPlay() : player.adDidPause()
            case .didChangeTimebaseRate(let rate): player.adUpdate(playback: rate == 1.0)
            case .playbackReady: player.adReady()
            case .playbackFailed(let error): player.adErrored(with: error as NSError)
            case .playbackFinished: player.adEndPlayback()
            case .durationReceived(let duration): player.adUpdate(duration: duration)
            case .currentTimeUpdated(let time): player.adUpdate(currentTime: time)
            case .bufferedTimeUpdated(let time): player.adUpdate(bufferedTime: time)
            case .averageVideoBitrateUpdated(let new): player.adUpdate(averageBitrate: new)
            case .pictureInPictureStopped: break
            case .pictureInPictureIsPossible: break
            case .externalPlaybackPossible(let status): player.adExternalPlaybackStatusChanged(status: status)
            case .externalPlaybackAllowance(let status): player.adExternalPlaybackAllowanceChanged(status: status)
            case .updateAudibleOptions: break
            case .updateLegibleOptions: break
            case .startDiscoveringMediaOptions: break
            case .didStartSeek, .didStopSeek: break
            case .contentFullScreenToggled: break
            case .playbackLikelyToKeepUp(let isPlayable):
                guard isPlayable else { break }
                player.updateAdPlaybackBufferingInactive()
            case .playbackBufferEmpty(let isEmpty):
                guard isEmpty else { break }
                player.updateAdPlaybackBufferingActive()
            }
        }
        
        return player.addObserver { props in
            guard let item = props.playbackItem else {
                let props: PlayerViewController.Props = {
                    guard
                        let error = props.errorItem else {
                            return .default()
                    }
                    return .unavailable(
                        error: error.reason,
                        playlist: contentControlsConnector(props).player?.playlist)
                }()
                return callback(props)
            }
            
            let context = contextPresenter.process(props)
            
            clickthroughDetector.process(props: props)
            
            func adControls() -> AdVideoControls.Props {
                let time = item.ad.time.static
                
                func click() -> CommandWith<SFSafariViewControllerDelegate> {
                    guard case .mp4 = item.adCreative else { return .nop }
                    return item.isClickThroughToggled ? .nop : CommandWith { _ in
                            player.activateClickThrough()
                        }
                }
                
                func accessibilityLabel() -> String {
                    guard let duration = time?.duration else { return "" }
                    guard let currentTime = time?.progress.value else { return "" }
                    guard let currentTimeString = TimeFormatter.voiceOverReadable(from: Int(currentTime)) else { return "" }
                    guard let durationString =  TimeFormatter.voiceOverReadable(from: Int(duration)) else { return "" }
                    return "Current position \(currentTimeString) of \(durationString))"
                }
                
                return AdVideoControls.Props(
                    mainAction: item.ad.isPlaying
                        ? .pause(CommandWith(action: player.pause))
                        : .play(CommandWith(action: player.play)),
                    seeker: item.ad.isSeekable == true
                        ? AdVideoControls.Props.Seeker(
                            remainingPlayTime: TimeFormatter.string(
                                from: Int(time?.remaining ?? 0.0)),
                            currentValue: time?.progress.value ?? 0.0,
                            accessibilityLabel: accessibilityLabel())
                        : nil,
                    click: click(),
                    isLoading: item.ad.isBuffering || item.ad.time.isUnknown,
                    airplayActiveViewHidden: item.ad.airPlay != .active
                )
            }
            
            func contentRenderer() -> Props.RendererProps? {
                guard item.content.status.isReady || item.content.status.isUndefined else { return nil }
                
                func rate() -> Float {
                    return item.content.isPlaying ? 1 : 0
                }
                
                let pictureInPictureActive: Bool = {
                    guard case .active = item.content.pictureInPictureMode else { return false }
                    return true
                }()
                
                let contentFullScreenActive: VideoRenderer.ResizeOptions = {
                    switch item.content.contentFullScreen {
                    case .active: return .resizeAspectFill
                    case .inactive,
                         .disabled: return .resizeAspect
                    }
                }()
                
                let allowsExternalPlayback: Bool = {
                    guard item.content.airPlay != .restricted else { return false }
                    guard context == .content else { return false }
                    return true
                }()
                
                let legible: AvailableMediaOptions.Option? = {
                    guard case .internal(let mediaGroup) = item.content.legible else { return nil }
                    guard let selectedOption = mediaGroup?.selectedOption else { return nil }
                    return .init(uuid: selectedOption.id, name: selectedOption.displayName)
                }()
                
                let audible: AvailableMediaOptions.Option? = {
                    guard let selectedOption = item.content.audible.selectedOption else { return nil }
                    return .init(uuid: selectedOption.id, name: selectedOption.displayName)
                }()
                
                let isFinished: Bool = VerizonVideoPartnerSDK.perform {
                    return item.content.time.static?.isFinished ?? item.content.time.live?.isFinished ?? true
                }
                
                return Props.RendererProps(
                    descriptor: Renderer.Descriptor(id: item.model.renderer.id,
                                                    version: item.model.renderer.version),
                    props: Renderer.Props(
                        context: "CONTENT",
                        angles: (vertical: item.videoAngles?.vertical ?? 0,
                                 horizontal: item.videoAngles?.horizontal ?? 0),
                        content: item.url,
                        rate: rate(),
                        isMuted: props.isMuted,
                        currentTime: item.content.time.static?.currentCMTime,
                        hasDuration: item.content.time.static?.duration != nil,
                        pictureInPictureActive: pictureInPictureActive,
                        allowsExternalPlayback: allowsExternalPlayback,
                        audible: audible,
                        legible: legible,
                        isFinished: isFinished,
                        videoResizeOptions: contentFullScreenActive),
                    dispatch: contentRendererDispatch)
            }
            
            func adRenderer() -> Props.RendererProps? {
                guard case .mp4(let creative) = item.adCreative, item.hasActiveAds else { return nil }
                func rate() -> Float {
                    return item.ad.isPlaying ? 1 : 0
                }
                let adProps: Props.RendererProps? = {
                    let allowsExternalPlayback: Bool = {
                        return item.ad.airPlay != .restricted && context == .ad
                    }()
                    func resize() -> VideoRenderer.ResizeOptions {
                        guard creative.scalable && !creative.maintainAspectRatio else { return .resizeAspect }
                        return .resize
                    }
                    
                    return Props.RendererProps(
                        descriptor: .flat,
                        props: Renderer.Props(
                            context: "AD",
                            angles: (0, 0),
                            content: creative.url,
                            rate: rate(),
                            isMuted: props.isMuted,
                            currentTime: item.ad.time.static?.currentCMTime,
                            hasDuration: item.ad.time.static?.duration != nil,
                            pictureInPictureActive: false,
                            allowsExternalPlayback: allowsExternalPlayback,
                            audible: nil,
                            legible: nil,
                            isFinished: false,
                            videoResizeOptions: resize()),
                        dispatch: adRendererDispatch)
                }()
                return adProps
            }
            
            func vpaidProps() -> VPAIDProps? {
                guard case .vpaid(let creative) = item.adCreative, item.hasActiveAds else { return nil }
                func rate() -> Float {
                    return item.ad.isPlaying ? 1 : 0
                }
                let url = creative.url.absoluteString
                let playbackProps = VPAIDProps.PlaybackProps(url: url,
                                                             adParameters: creative.adParameters,
                                                             rate: rate(),
                                                             isMuted: props.isVPAIDMuted,
                                                             isSessionCompleted: props.isSessionCompleted)
                return VPAIDProps(documentUrl: props.vpaidDocument,
                                  playbackProps: playbackProps)
            }
            func vpaidDispatch(event: VPAIDEvents) {
                player.updateVPAIDAdState(with: event)
            }
            
            callback(Props(
                content: contentRenderer(),
                ad: adRenderer(),
                vpaidDispatch: vpaidDispatch,
                vpaidProps: vpaidProps(),
                contentControls: contentControlsConnector(props),
                adControls: adControls(),
                activeContext: context))
        }
    }
}

extension MediaOptions.Option {
    init(availableOption: AvailableMediaOptions.Option) {
        self.init(uuid: availableOption.uuid, displayName: availableOption.name)        
    }
}

