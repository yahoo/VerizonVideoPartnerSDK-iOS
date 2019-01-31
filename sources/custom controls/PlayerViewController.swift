//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import UIKit
import PlayerControls
import VideoRenderer
import WebKit

/// `PlayerViewController` which has `PlayerView` inside.
/// Responsible for binding `PlayerView` to the `Player`.
/// Reacts on events from `Player` and sends action to `Player`.
public final class PlayerViewController: UIViewController {
    
    private var loadingImageView: LoadingImageView?
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDidHide()
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
    
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidShow()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(viewDidHide),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(viewDidShow),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
    
    var isAppeared = false
    
    @objc func viewDidHide() {
        isAppeared = false
        player?.update(playerDimensions: nil)
    }
    
    @objc func viewDidShow() {
        isAppeared = true
        player?.update(playerDimensions: view.bounds.size)
    }
    
    public override func loadView() {
        super.loadView()
        
        view.backgroundColor = .black
        
        /* Create -> configure -> add controls to ad video view */ do {
            adControls = AdVideoControls()
            addChild(adControls)
            adControls.view.frame = view.bounds
            adControls.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(adControls.view)
            adControls.didMove(toParent: self)
        }
        
        /* Create -> configure -> add loading indicator to video view */ do {
            let loadingImage = UIImage(named: "icon-loading", in: Bundle(for: AdVideoControls.self), compatibleWith: view.traitCollection)
            let loadingImageView = LoadingImageView(image: loadingImage)
            view.addSubview(loadingImageView)
            loadingImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([loadingImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                         loadingImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
            loadingImageView.isHidden = true
            self.loadingImageView = loadingImageView
        }
        
        // Images of UIButton's are taken
        // with correct size class after this call.
        view.layoutIfNeeded()
    }
    
    struct Props {
        struct RendererProps {
            let descriptor: Renderer.Descriptor
            let props: Renderer.Props?
            let dispatch: Renderer.Dispatch?
        }
        
        let content: RendererProps?
        let ad: RendererProps?
        
        let vpaidDispatch: VPAIDDispatch?
        let vpaidProps: VPAIDProps?
        
        let contentControls: ContentControlsViewController.Props
        let adControls: AdVideoControls.Props
        let activeContext: VideoContextPresenter.Output
        
        static func `default`() -> Props {
            return Props(
                content: .init(descriptor: .init(id: "undefined", version: "undefined"),
                               props: nil,
                               dispatch: nil),
                ad: .init(descriptor: .init(id: "undefined", version: "undefined"),
                          props: nil,
                          dispatch: nil),
                vpaidDispatch: nil,
                vpaidProps: nil,
                contentControls: .noPlayer,
                adControls: AdVideoControls.Props.default,
                activeContext: .empty)
        }
        
        static func unavailable(error: String, playlist: ContentControlsViewController.Props.Playlist?) -> Props {
            return Props(
                content: .init(descriptor: .init(id: "undefined", version: "undefined"),
                               props: nil,
                               dispatch: nil),
                ad: .init(descriptor: .init(id: "undefined", version: "undefined"),
                          props: nil,
                          dispatch: nil),
                vpaidDispatch: nil,
                vpaidProps: nil,
                contentControls: .player(ContentControlsViewController.Props.Player {
                    $0.playlist = playlist
                    $0.item = .nonplayable(error)
                }),
                adControls: AdVideoControls.Props.default,
                activeContext: .content)
        }
    }
    
    var props = Props.default() {
        didSet {
            guard isViewLoaded else { return }
            
            contentControlsViewController?.props = {
                guard let customized = customizeContentControlsProps?(props.contentControls)
                    else { return props.contentControls }
                
                return customized
            }()
            
            adControls.props = props.adControls
            
            if oldValue.ad?.descriptor != props.ad?.descriptor || adRenderer == nil {
                if let newDescriptor = props.ad?.descriptor {
                    adRenderer = Renderer.Repository.shared.makeViewControllerFor(
                        descriptor: newDescriptor)
                }
            }
            
            adRenderer?.dispatch = props.ad?.dispatch
            adRenderer?.props = props.ad?.props
            
            if oldValue.content?.descriptor != props.content?.descriptor || contentRenderer == nil {
                if let newDescriptor = props.content?.descriptor {
                    contentRenderer = Renderer.Repository.shared.makeViewControllerFor(
                        descriptor: newDescriptor)
                }
            }
            
            if props.content?.props?.isFinished == true {
                if let controller = presentedViewController as? SettingsViewController {
                    controller.dismiss(animated: true, completion: nil)
                }
            }
            if let vpaidProps = props.vpaidProps {
                if vpaidViewController == nil {
                    vpaidViewController = WebviewViewController(props: vpaidProps)
                }
                vpaidViewController?.props = vpaidProps
                vpaidViewController?.dispatch = props.vpaidDispatch
            } else {
                vpaidViewController = nil
            }
            contentRenderer?.dispatch = props.content?.dispatch
            contentRenderer?.props = props.content?.props
            
            loadingImageView?.isLoading = props.activeContext == .empty
            
            view.setNeedsLayout()
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contentControlsViewController?.view.isHidden = {
            guard case .content = props.activeContext else { return true }
            
            return false
        }()
        
        adControls.view.isHidden = {
            guard case .ad = props.activeContext else { return true }
            
            return false
        }()
        
        contentRenderer?.viewController.view.isHidden = {
            guard case .content = props.activeContext else { return true }
            
            return false
        }()
        
        adRenderer?.viewController.view.isHidden = {
            guard case .ad = props.activeContext else { return true }
            guard let item = player?.store.props.playbackItem else { return true }
            guard item.mp4AdCreative != nil else { return true }
            return false
        }()
        vpaidViewController?.view.isHidden = {
            guard case .ad = props.activeContext else { return true }
            guard let item = player?.store.props.playbackItem else { return true }
            guard item.vpaidAdCreative != nil else { return true }
            return false
        }()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard isAppeared else { return }
        player?.update(playerDimensions: view.bounds.size)
    }
    
    private func toggleSettings() {
        if let controller = presentedViewController as? SettingsViewController {
            controller.dismiss(animated: true, completion: nil)
        } else {
            guard let contentControls = contentControlsViewController else { return }
            
            let settingsViewController = SettingsViewController()
            settingsViewController.props = ContentControlsViewController.settingProps(from: contentControls.props)
            contentControlsViewController?.settingsViewController = settingsViewController
            settingsViewController.modalPresentationStyle = .overFullScreen
            settingsViewController.modalTransitionStyle = .crossDissolve
            
            let viewController = presentedViewController ?? self
            viewController.present(settingsViewController,
                                   animated: true,
                                   completion: nil)
        }
    }
    
    var unbindCurrentPlayer = nil as Player.PropsObserverDispose?
    /// Drop configured `Player` instance here.
    public var player: Player? {
        willSet {
            unbindCurrentPlayer?()
            
            if let player = player, let item = player.props.playbackItem,
                case .active = item.content.pictureInPictureMode {
                player.togglePictureInPictureMode()
            }
            
            props = Props.default()
            player?.update(playerDimensions: nil)
        }
        didSet {
            guard let player = player else { return }
            
            unbindCurrentPlayer = PlayerViewController.bind(
                player: player,
                toggleSettings: { [weak self] in
                    guard let `self` = self else { return }
                    self.toggleSettings()
                },
                showSafari: { url, delegate in
                    #if os(iOS)
                    DispatchQueue.main.async {
                        openSafari(with: url, delegate: delegate)
                    }
                    #endif
                },
                adViewAction: { [weak self] in
                    return self?.adRenderer?.viewController.viewIfLoaded
                },
                callback: { [weak self] props in
                    self?.props = props
            })
            
            guard isAppeared else { return }
            player.update(playerDimensions: view.bounds.size)
        }
    }
    
    var channel: Telemetry.Channel!
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        channel = Telemetry.Station.shared.makeChannel(for: self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        channel = Telemetry.Station.shared.makeChannel(for: self)
    }
    
    deinit {
        player?.update(playerDimensions: nil)
        unbindCurrentPlayer?()
        NotificationCenter.default.removeObserver(self)
    }
    
    private var contentRenderer: RendererProtocol? {
        willSet {
            guard let vc = contentRenderer?.viewController else { return }
            
            vc.beginAppearanceTransition(false, animated: false)
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
            vc.endAppearanceTransition()
        }
        didSet {
            guard let vc = contentRenderer?.viewController else { return }
            
            vc.beginAppearanceTransition(true, animated: false)
            vc.willMove(toParent: self)
            addChild(vc)
            vc.view.frame = view.bounds
            vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(vc.view, at: 0)
            vc.didMove(toParent: self)
            vc.endAppearanceTransition()
        }
    }
    
    private var adRenderer: RendererProtocol? {
        willSet {
            guard let vc = adRenderer?.viewController else { return }
            
            vc.beginAppearanceTransition(false, animated: false)
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
            vc.endAppearanceTransition()
        }
        didSet {
            guard let vc = adRenderer?.viewController else { return }
            
            vc.beginAppearanceTransition(true, animated: false)
            vc.willMove(toParent: self)
            vc.view.frame = adControls.containerView.bounds
            vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            adControls.containerView.addSubview(vc.view)
            vc.didMove(toParent: self)
            vc.endAppearanceTransition()
        }
    }
    
    /// Content Video Controls View Controller. You can assign
    /// `DefaultControlsViewController` if you want to use default UI controls.
    public var contentControlsViewController: ContentControlsViewController? = nil {
        willSet {
            guard let vc = contentControlsViewController else { return }
            
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
        didSet {
            guard let vc = contentControlsViewController else { return }
            
            vc.willMove(toParent: self)
            vc.view.removeFromSuperview()
            addChild(vc)
            vc.view.frame = view.bounds
            vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(vc.view)
            vc.didMove(toParent: self)
        }
    }
    
    var vpaidViewController: WebviewViewController? = nil {
        willSet {
            guard let vc = vpaidViewController else { return }
            
            vc.beginAppearanceTransition(false, animated: false)
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
            vc.endAppearanceTransition()
        }
        didSet {
            guard let vc = vpaidViewController else { return }
            
            vc.beginAppearanceTransition(true, animated: false)
            vc.willMove(toParent: self)
            vc.view.frame = adControls.containerView.bounds
            vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            adControls.containerView.addSubview(vc.view)
            vc.didMove(toParent: self)
            vc.endAppearanceTransition()
        }
    }
    
    /// This lambda is the point of UI and behavior customisation.
    /// You need to return modified version of props -
    /// and they will be applied.
    public var customizeContentControlsProps:(
    (ContentControlsViewController.Props) -> ContentControlsViewController.Props)?
    
    /// Advertisement Video Controls.
    public private(set)var adControls: AdVideoControls!

}
