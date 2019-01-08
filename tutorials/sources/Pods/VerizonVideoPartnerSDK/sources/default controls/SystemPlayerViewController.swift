//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import AVKit
import AVFoundation
import VideoRenderer

/// View Controller that has `AVPlayerViewController`
/// for playing content and advertisement videos.
/// This view controller could be presented full screen.
/// If controller is presented in container view (not fullscreen)
/// than only play/pause controls will work.
@available(tvOS 9.0, *)
public final class SystemPlayerViewController: UIViewController {
    
    /// Set configured `Player` here from SDK to
    /// begin playing videos.
    /// Set this property to nil if you no longer
    /// need `Player` and want to dispose associated resources.
    public var player: Player? {
        didSet {
            updatePlayerBindings()
            DispatchQueue.main.async { self.player?.update(playerDimensions: self.view.bounds.size) }
        }
    }
    
    let playerViewController = AVPlayerViewController()
    
    var advertisementLabel = UILabel()
    var unavailableVideoLabel = UILabel()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(playerViewController)
        playerViewController.view.frame = view.bounds
        playerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)
        
        advertisementLabel.text = "Advertisement"
        advertisementLabel.textColor = UIColor(
            red: 1.0, green: 198.0 / 255.0, blue: 0, alpha: 1.0)
        advertisementLabel.font = .boldSystemFont(ofSize: 24)
        advertisementLabel.sizeToFit()
        advertisementLabel.isHidden = true
        playerViewController.contentOverlayView?.addSubview(advertisementLabel)
        
        unavailableVideoLabel.textColor = .white
        unavailableVideoLabel.font = .boldSystemFont(ofSize: 24)
        unavailableVideoLabel.isHidden = true
        playerViewController.contentOverlayView?.addSubview(unavailableVideoLabel)
        
        updatePlayerBindings()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        player?.update(playerDimensions: view.bounds.size)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        advertisementLabel.center = CGPoint(
            x: view.center.x,
            y: advertisementLabel.frame.height / 2 + 60
        )
        
        advertisementLabel.isHidden = {
            guard case .available(let player) = props else { return true }
            return player.isAdLabelHidden
        }()
        
        unavailableVideoLabel.isHidden = {
            guard case .unavailable = props else { return true }
            return false
        }()
        
        unavailableVideoLabel.text = {
            guard case .unavailable(let reason) = props else { return "" }
            return reason
        }()
        
        unavailableVideoLabel.sizeToFit()
        unavailableVideoLabel.center = CGPoint(
            x: view.center.x,
            y: view.center.y - 100
        )
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        player?.update(playerDimensions: nil)
    }
    
    var disposable: Disposable? = nil
    func updatePlayerBindings() {
        guard isViewLoaded else { return }
        disposable = SystemPlayerViewController.bindPlayer(player: player) { [weak self] in
            self?.props = $0
        }
    }
    
    final class Context {
        let player = AVPlayer()
        
        private var seekerController: SeekerController?
        private var systemPlayerObserver = nil as SystemPlayerObserver?
        private var timeObserver = nil as Any?
        private var replayDetector = nil as ReplayDetector?
        
        init() {
            replayDetector = ReplayDetector { [unowned self] in
                self.replay()
                guard let duration = self.player.currentItem?.duration else { return }
                self.handleEvent(event: .didChangeItemDuration(to: duration))
            }
            systemPlayerObserver = SystemPlayerObserver(player: player) { [unowned self] in
                self.replayDetector?.props.event = $0
                self.handleEvent(event: $0)
            }
        }
        
        private func replay() {
            props?.replay?(())
        }
        
        private func handleEvent(event: SystemPlayerObserver.Event) {
            props?.handleEvent?(event)
        }
        
        private func updateTime(time: CMTime) {
            props?.updateTime?(time)
        }
        
        private func handleCIFilter(request: AVAsynchronousCIImageFilteringRequest) {
            props?.ciFilterHandler?(request)
        }
        
        var props = nil as PlayerProps? {
            didSet {
                guard let props = props else {
                    if let timeObserver = timeObserver {
                        player.removeTimeObserver(timeObserver)
                    }
                    timeObserver = nil
                    
                    replayDetector?.props = .init()
                    player.replaceCurrentItem(with: nil)
                    seekerController = nil
                    return
                }
                
                let asset = player.currentItem?.asset as? AVURLAsset
                if asset?.url != props.url {
                    if let timeObserver = timeObserver {
                        player.removeTimeObserver(timeObserver)
                    }
                    timeObserver = nil
                    
                    player.replaceCurrentItem(with: AVPlayerItem(url: props.url))
                    seekerController = SeekerController(with: player, context: "") { [weak self] in
                        guard let `self` = self else { return }
                        switch $0 {
                        case .startSeek: self.handleEvent(event: .startSeek)
                        case .stopSeek: self.handleEvent(event: .stopSeek)
                        }
                    }
                }
                
                guard player.currentItem?.status == .readyToPlay else { return }
                
                if props.rate != player.rate {
                    player.rate = props.rate
                }
                
                seekerController?.process(to: props.currentTime)
                
                player.isMuted = props.isMuted
                player.currentItem?.externalMetadata = props.metadata
                
                if props.cuePoints.count > 0 {
                    player.currentItem?.interstitialTimeRanges = props.cuePoints
                } else {
                    player.currentItem?.interstitialTimeRanges.removeAll()
                }
                
                switch (props.ciFilterHandler, player.currentItem?.videoComposition) {
                case (.some, .none):
                    guard let item = player.currentItem else { return }
                    item.videoComposition = AVVideoComposition(asset: item.asset) { [unowned self] request in
                        self.handleCIFilter(request: request)
                    }
                case (.none, .some):
                    player.currentItem?.videoComposition = nil
                default: break
                }
                
                if timeObserver == nil {
                    timeObserver = player.addPeriodicTimeObserver(
                        forInterval: CMTime(seconds: 0.2, preferredTimescale: 600),
                        queue: .main) { [unowned self] in
                            self.replayDetector?.props.time = $0
                            guard self.replayDetector?.endPlaybackDetected == false else { return }
                            self.seekerController?.currentTime = $0
                            self.updateTime(time: $0)
                    }
                }
            }
        }
        
        deinit {
            if let timeObserver = timeObserver {
                player.removeTimeObserver(timeObserver)
            }
        }
    }
    
    struct PlayerProps {
        let url: URL
        let rate: Float
        let currentTime: CMTime?
        let isMuted: Bool
        let updateTime: Action<CMTime>?
        let replay: Action<Void>?
        let handleEvent: Action<SystemPlayerObserver.Event>?
        var metadata: [AVMetadataItem]
        var ciFilterHandler: Action<AVAsynchronousCIImageFilteringRequest>?
        let cuePoints: [AVInterstitialTimeRange]
    }
    
    enum Props {
        case available(Player)
        case unavailable(String)
        
        struct Player {
            let content: PlayerProps?
            let ad: PlayerProps?
            
            let active: VideoContextPresenter.Output
            let requiresLinearPlayback: Bool
            let isAdLabelHidden: Bool
            
            static let `default` = Player(content: nil,
                                          ad: nil,
                                          active: .empty,
                                          requiresLinearPlayback: false,
                                          isAdLabelHidden: true)
        }
    }
    
    var contentContext = Context()
    var adContext = Context()
    
    var props = Props.available(Props.Player.default) {
        didSet {
            guard isViewLoaded else { return }
            playerViewController.player = {
                guard case .available(let props) = props else { return nil }
                switch props.active {
                case .empty: return nil
                case .ad: return adContext.player
                case .content: return contentContext.player
                }
            }()
            
            adContext.props = {
                guard case .available(let props) = props else { return nil }
                return props.ad
            }()
            
            contentContext.props = {
                guard case .available(let props) = props else { return nil }
                var contentProps = props.content
                contentProps?.metadata.append(contentsOf: contentVideoMetadata)
                contentProps?.ciFilterHandler = contentCIFilterHandler
                return contentProps
            }()
            
            playerViewController.requiresLinearPlayback = {
                guard case .available(let props) = props else { return false }
                return props.requiresLinearPlayback
            }()
            
            DispatchQueue.main.async { self.view.setNeedsLayout() }
        }
    }
    
    //swiftlint:enable cyclomatic_complexity
    //swiftlint:enable function_body_length
    
    /// This metadata will be set to the `AVPlayer` current
    /// item `externalMetadata` property.
    /// If the `AVPlayer.currentItem` is nil - metadata will be set
    /// as soon as current item will be created.
    /// Metadata will be set ONLY for content video.
    /// The advertisement video has no metadata by default.
    public var contentVideoMetadata: [AVMetadataItem] = []
    
    /// You can add CIFilter to the content video
    /// by passing handler to this variable.
    public var contentCIFilterHandler: Action<AVAsynchronousCIImageFilteringRequest>?
    
    var channel: Telemetry.Channel!
    
    public var contentPlayer: AVPlayer {
        get {
            return contentContext.player
        }
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        channel = Telemetry.Station.shared.makeChannel(for: self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        channel = Telemetry.Station.shared.makeChannel(for: self)
    }
    
    deinit {
        disposable = nil
    }
}
