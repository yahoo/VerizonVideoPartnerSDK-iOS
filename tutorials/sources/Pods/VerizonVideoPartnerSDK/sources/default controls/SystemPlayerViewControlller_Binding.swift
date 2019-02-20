//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import CoreMedia
import VideoRenderer
import AVFoundation
import AVKit

extension SystemPlayerViewController {
    //swiftlint:disable cyclomatic_complexity
    //swiftlint:disable function_body_length
    static func bindPlayer(player: Player?,
                           setter: @escaping (Props) -> Void) -> Disposable {
        let disposable = Disposable()
        guard let player = player else { return disposable }
        
        disposable.append {
            DispatchQueue.main.async {
                setter(Props.available(Props.Player.default))
            }
        }
        
        let contextPresenter = VideoContextPresenter()
        
        func contentDidChangeRateTo(to new: Float) {
            if new == 1.0 { player.play() }
            else {
                guard player.props.playbackItem?.hasActiveAds == false else { return }
                player.pause()
            }
        }
        
        func contentDidChangeExternalPlaybackStatus(to new: Bool) {
            player.contentExternalPlaybackAllowanceChanged(status: new)
        }
        
        func contentDidChangeExternalPlaybackAllowance(to new: Bool) {
            player.contentExternalPlaybackAllowanceChanged(status: new)
        }
        
        func contentDidChangeTimebaseRateTo(to new: Float) {
            player.update(playback: new == 1.0)
        }
        
        func contentEventHandler(_ event: SystemPlayerObserver.Event) {
            switch event {
            case .didChangeRate(let new): contentDidChangeRateTo(to: new)
            case .didChangeExternalPlaybackStatus(let new): contentDidChangeExternalPlaybackStatus(to: new)
            case .didChangeExternalPlaybackAllowance(let new): contentDidChangeExternalPlaybackAllowance(to: new)
            case .didChangeTimebaseRate(let new): contentDidChangeTimebaseRateTo(to: new)
            case .didChangeItemDuration(let new): player.update(duration: new)
            case .didFinishPlayback: player.endPlayback()
            case .didChangeAverageVideoBitrate(let new): player.update(averageBitrate: new)
            case .didChangeItemStatusToReadyToPlay: player.contentReady()
            case .startSeek: player.didStartSeek()
            case .stopSeek: player.didStopSeek()
            default: break
            }
        }
        
        func adDidChangeRateTo(to new: Float) {
            new == 1.0 ? player.play() : player.pause()
        }
        
        func adDidChangeTimebaseRateTo(to new: Float) {
            player.adUpdate(playback: new == 1.0)
        }
        
        func adDidEnd() {
            player.adEndPlayback()
            
            if player.props.isPlaybackInitiated { player.play() }
        }
        
        func adEventHandler(_ event: SystemPlayerObserver.Event) {
            switch event {
            case .didChangeRate(let new): adDidChangeRateTo(to: new)
            case .didChangeTimebaseRate(let new): adDidChangeTimebaseRateTo(to: new)
            case .didChangeItemDuration(let new): player.adUpdate(duration: new)
            case .didFinishPlayback: adDidEnd()
            case .didChangeItemStatusToFailed(let error): player.adErrored(with: error as NSError)
            case .didReceivePlayerError(let error): player.adErrored(with: error as NSError)
            case .didChangeItemStatusToReadyToPlay: player.adReady()
            default: break
            }
        }
        
        disposable.append(dispose: player.addObserver { props in
            let controllerProps: Props = {
                switch props.item {
                case .available(let videoProps):
                    let content = PlayerProps(
                        url: videoProps.url,
                        rate: videoProps.content.isPlaying ? 1.0 : 0.0,
                        currentTime: videoProps.content.time.static?.currentCMTime,
                        isMuted: props.isMuted,
                        updateTime: player.update(currentTime:),
                        replay: player.replay,
                        handleEvent: contentEventHandler,
                        metadata: [],
                        ciFilterHandler: nil,
                        cuePoints: VerizonVideoPartnerSDK.perform {
                            guard let item = props.playbackItem else { return [] }
                            
                            return item.midrolls
                                .filter  { item.playedAds.contains($0.id) == false }
                                .map {
                                    let timeRange = CMTimeRange(
                                        start: CMTimeMakeWithSeconds(Float64($0.cuePoint), preferredTimescale: 600),
                                        duration: CMTime.zero)
                                    return AVInterstitialTimeRange(timeRange: timeRange) }})
                    
                    let adProps: PlayerProps? = {
                        guard let model = videoProps.mp4AdCreative, videoProps.hasActiveAds else { return nil }
                        
                        return PlayerProps(
                            url: model.url,
                            rate: videoProps.ad.isPlaying ? 1.0 : 0.0,
                            currentTime: nil,
                            isMuted: props.isMuted,
                            updateTime: player.adUpdate(currentTime:),
                            replay: nil,
                            handleEvent: adEventHandler,
                            metadata: [],
                            ciFilterHandler: nil,
                            cuePoints: [])
                    }()
                    
                    return Props.available(Props.Player(
                        content: content,
                        ad: adProps,
                        active: contextPresenter.process(props),
                        requiresLinearPlayback: videoProps.hasActiveAds,
                        isAdLabelHidden: videoProps.hasActiveAds == false || videoProps.isAdPlaying == false))
                case .unavailable(let props):
                    return Props.unavailable(props.reason)
                }
            }()
            setter(controllerProps)
        })
        
        return disposable
    }
}
