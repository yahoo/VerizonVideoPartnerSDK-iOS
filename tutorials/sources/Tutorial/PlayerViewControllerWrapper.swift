//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import UIKit
import VerizonVideoPartnerSDK
import PlayerControls


class PlayerViewControllerWrapper: UIViewController {
    struct Props {
        var controls = Controls()
        
        struct Controls {
            var color = UIColor.magenta
            var isSomeHidden = false
            var liveDotColor: UIColor?
            var sidebarProps: SideBarView.Props = []
            var isFilteredSubtitles = false
            var isAnimationsDisabled = false
            var isCustomColorsMode = false
        }
        
        var showStats = false
        
        struct Stats {
            var isPlaying = false
            var currentTime: Double = 0
            
            enum VideoType { case live, vod(is360: Bool), unknown }
            var videoType = VideoType.unknown
        }
        var stats = Stats()
        
        var looping = false
        var nextVideoHooking = false
        
        var isLoading = false
        var isLastVideoFinished = false
        
        var error: Error?
    }
    
    private var playerPropsObserverDispose: Player.PropsObserverDispose?
    var player: Future<Result<Player>>? {
        willSet {
            playerPropsObserverDispose?()
            playerViewController?.player = nil
        }
        didSet {
            guard let player = player else { return }
            props.isLoading = true
            player
                .dispatch(on: .main)
                .onSuccess(call: render)
                .onError(call: render)
                .onComplete { [weak self] _ in self?.props.isLoading = false }
        }
    }
    var props = Props() {
        didSet {
            view.setNeedsLayout()
            guard props.looping && props.isLastVideoFinished else { return }
            playerViewController?.player?.selectVideo(atIndex: 0)
        }
    }
    @IBOutlet weak private var statusViewHiddenBottomConstaint: NSLayoutConstraint!
    @IBOutlet weak private var statusViewShownBottomConstaint: NSLayoutConstraint!
    @IBOutlet weak private var statsView: UIView!
    @IBOutlet weak private var isPlayingLabel: UILabel!
    @IBOutlet weak private var currentTimeLabel: UILabel!
    @IBOutlet weak private var videoTypeLabel: UILabel!
    @IBOutlet weak private var activityIndicatorView: UIActivityIndicatorView!
    private var playerViewController: PlayerViewController? {
        return childViewControllers.first as? PlayerViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Using default controls but it's possible to use custom by subclassing from ContentControlsViewController and set it to contentControlsViewController
        let defaultControlsViewController = DefaultControlsViewController()
        // Values to change controls animation duration.
        // If one of the control items appear/dissapear, his default value will be equal to appearance animation.
        defaultControlsViewController.controlsAppearanceAnimationDuration = 0.25
        defaultControlsViewController.controlsDisappearanceAnimationDuration = 0.35
        playerViewController?.contentControlsViewController = defaultControlsViewController
    }
    
    // You should override this method and return contentControlsViewController to turn on
    // home indicator auto-hidden behaviour if player controls are hidden.
    @available(iOS 11, *)
    override func childViewControllerForHomeIndicatorAutoHidden() -> UIViewController? {
        return playerViewController?.contentControlsViewController
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        activityIndicatorView.isHidden = !props.isLoading
        props.isLoading ?
            activityIndicatorView.startAnimating() :
            activityIndicatorView.stopAnimating()
        
        // Changing color of content view controller controls
        playerViewController?.view.tintColor = props.controls.color
        
        // Adding sidebar buttons
        if let defaultControlsViewController = playerViewController?.contentControlsViewController as? DefaultControlsViewController {
            defaultControlsViewController.sidebarProps = props.controls.sidebarProps
        }
        
        statsView.isHidden = !props.showStats
        statusViewHiddenBottomConstaint.isActive = !props.showStats
        statusViewShownBottomConstaint.isActive = props.showStats
        
        if let error = props.error { render(error: error) }
        
        guard props.showStats else { return }
        isPlayingLabel.text = String(props.stats.isPlaying)
        currentTimeLabel.text = String(format: "%.1fs", props.stats.currentTime)
        
        switch props.stats.videoType {
        case .live: videoTypeLabel.text = "live"
        case .vod(let is360): videoTypeLabel.text = "vod" + (is360 ? ", 360" : "")
        default: videoTypeLabel.text = "unknown"
        }
    }
    
    private func render(error: Error) {
        let alert = UIAlertController(title: "Error",
                                      message: "\(error)",
            preferredStyle: .alert)
        alert.addAction(.init(title: "OK",
                              style: .default,
                              handler: nil))
        present(alert,
                animated: true,
                completion: nil)
    }
    
    private func render(player: Player) {
        typealias Controls = PlayerControls.ContentControlsViewController.Props.Controls
        
        playerViewController?.customizeContentControlsProps = { [weak self] props in
            guard let strongSelf = self else { return props }
            // Modifying content props only if content video can be played
            guard var contentPlayer = props.player else { return props }
            guard var controls = contentPlayer.item.playable else { return props }
            
            func changeControlsLiveDot() {
                controls.live.dotColor = strongSelf.props.controls.liveDotColor.map(Color.init)
            }
            
            func hideSomeControls() {
                guard strongSelf.props.controls.isSomeHidden else { return }
                controls.seekbar?.seeker.seekTo = nil
                controls.settings = .hidden
            }
            
            func filteredSubtitles() {
                guard strongSelf.props.controls.isFilteredSubtitles else { return }
                guard var group = controls.legible else { return }
                group.options = group.options.filter { !$0.name.contains("CC") }
                controls.legible = group
            }
            
            func disabledAnimations() {
                guard strongSelf.props.controls.isAnimationsDisabled else { return }
                controls.animationsEnabled = false
            }
            func customSeekbarColors() {
                guard strongSelf.props.controls.isCustomColorsMode else { return }
                //Constructor have default values, so you can setup only those elements that you want
                controls.seekbar?.seekbarColors = .init(currentTimeColor: Color(.white),
                                                        progressColor: Color(.white),
                                                        bufferedColor: Color(.cyan),
                                                        fillerColor: Color(.cyan),
                                                        cuePointsColor: Color(.white),
                                                        dragControlColor: Color(.white))
            }
            
            let customNextCommand: Command? = {
                let nextIndex: Int = Int(arc4random_uniform(UInt32(player.props.playlist.count+1)))
                let command: Command? = {
                    if strongSelf.props.nextVideoHooking {
                        return Command { player.selectVideo(atIndex: nextIndex) }
                    }
                    if strongSelf.props.looping && !player.props.playlist.hasNextVideo {
                        return Command { player.selectVideo(atIndex: 0) }
                    }
                    if player.props.playlist.hasNextVideo {
                        return Command(action: player.nextVideo)
                    }
                    return nil
                }()
                switch player.props.item {
                case .available(let item): return item.content.isSeeking ? nil : command
                case .unavailable: return command
                }
            }()
            let customPrevCommand: Command? = {
                let command: Command? = {
                    if strongSelf.props.looping && !player.props.playlist.hasPrevVideo {
                        return Command { player.selectVideo(atIndex: player.props.playlist.count-1) }
                    }
                    if player.props.playlist.hasPrevVideo {
                        return Command(action: player.prevVideo)
                    }
                    return nil
                }()
                switch player.props.item {
                case .available(let item): return item.content.isSeeking ? nil : command
                case .unavailable: return command
                }
            }()
            
            changeControlsLiveDot()
            hideSomeControls()
            filteredSubtitles()
            disabledAnimations()
            customSeekbarColors()
            
            contentPlayer.playlist?.next = customNextCommand
            contentPlayer.playlist?.prev = customPrevCommand
            contentPlayer.item = .playable(controls)
            
            var props = props
            props = .player(contentPlayer)
            
            return props
        }
        
        playerPropsObserverDispose = player.addObserver { [weak self] props in
            guard let strongSelf = self else { return }
            
            strongSelf.props.stats = {
                guard let item = props.playbackItem else { return .init() }
                let isStreamPlaying = item.ad.isPlaying || item.content.isPlaying
                let currentTime = item.ad.time.static?.current ?? item.content.time.static?.current ?? 0
                let videoType: PlayerViewControllerWrapper.Props.Stats.VideoType = {
                    if item.content.time.isLive || item.ad.time.isLive { return .live }
                    if item.content.time.isStatic || item.ad.time.isStatic { return .vod(is360: item.videoAngles != nil) }
                    return .unknown
                }()
                
                return .init(isPlaying: isStreamPlaying,
                             currentTime: currentTime,
                             videoType: videoType)
            }()
            strongSelf.props.isLastVideoFinished = {
                guard let item = props.playbackItem else { return false }
                guard item.content.time.static?.isFinished ?? item.content.time.live?.isFinished ?? false else { return false }
                guard !props.playlist.hasNextVideo else { return false }
                return true
            }()
            strongSelf.props.error = {
                switch props.item {
                case .available(let item):
                    guard case .failed(let playbackError) = item.content.status else { return nil }
                    return playbackError
                case .unavailable(let unavailable):
                    struct VideoError: Swift.Error { let reason: String }
                    return VideoError(reason: unavailable.reason)
                }
            }()
        }
        
        playerViewController?.player = player
    }
}
