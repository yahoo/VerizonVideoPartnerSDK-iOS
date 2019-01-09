//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import GLKit
import AVFoundation

private let sharedContext: EAGLContext = {
    guard let context = EAGLContext(api: .openGLES3) ?? EAGLContext(api: .openGLES2) else {
        fatalError("Unable to initialise both OpenGL 3 and 2!")
    }
    return context
}()

extension Renderer.Descriptor {
    public static let sphere = Renderer.Descriptor(
        id: "com.onemobilesdk.videorenderer.360",
        version: "1.0"
    )
}

public class SphereVideoStreamViewController: GLKViewController, RendererProtocol, GLKViewControllerDelegate {
    public static let renderer = Renderer(
        descriptor: .sphere,
        provider: { SphereVideoStreamViewController() }
    )
    
    private var player: AVPlayer?
    private var output: AVPlayerItemVideoOutput?
    private var observer: SystemPlayerObserver?
    private var timeObserver: Any?
    private var seekerController: SeekerController? = nil
    
    var sphereview: SphereView? {
        return view as? SphereView
    }
    
    public override func loadView() {
        view = SphereView()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        EAGLContext.setCurrent(sharedContext)
        sphereview?.context = sharedContext
        sphereview?.buildSphere()
    }
    
    deinit {
        if EAGLContext.current() == sphereview?.context {
            EAGLContext.setCurrent(nil)
        }
    }
    
    public func glkViewControllerUpdate(_ controller: GLKViewController) {
        guard player?.currentItem?.status == .readyToPlay else { return }
        
        guard let currentTime = player?.currentTime() else { return }
        
        guard let pixelBuffer = output?.copyPixelBuffer(
            forItemTime: currentTime,
            itemTimeForDisplay: nil) else { return }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            preconditionFailure("Pixel buffer base address is nil!")
        }
        
        sphereview?.updateTexture(
            size: CGSize(width: width, height: height),
            imageData: baseAddress)
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
    }
    
    public var dispatch: Renderer.Dispatch?
    public var props: Renderer.Props? {
        didSet {
            guard let props = props, view.window != nil else {
                if let timeObserver = timeObserver {
                    player?.removeTimeObserver(timeObserver)
                }
                
                player?.replaceCurrentItem(with: nil)
                output = nil
                observer = nil
                timeObserver = nil
                seekerController = nil
                
                return
            }
            
            let currentPlayer: AVPlayer
            
            if
                let player = player,
                let asset = player.currentItem?.asset as? AVURLAsset,
                props.content == asset.url
            {
                currentPlayer = player
            } else {
                if let timeObserver = timeObserver {
                    player?.removeTimeObserver(timeObserver)
                }
                timeObserver = nil
                
                currentPlayer = AVPlayer(url: props.content)
                
                observer = SystemPlayerObserver(player: currentPlayer) { [weak self] event in
                    switch event {
                    case .didChangeItemStatusToReadyToPlay:
                        self?.dispatch?(.playbackReady)
                    case .didChangeItemStatusToFailed(let error):
                        self?.dispatch?(.playbackFailed(error))
                    case .didChangeRate(let new):
                        self?.dispatch?(.didChangeRate(new))
                    case .didChangeTimebaseRate(let new):
                        self?.dispatch?(.didChangeTimebaseRate(new))
                    case .didChangeItemDuration(let new):
                        self?.dispatch?(.durationReceived(new))
                    case .didFinishPlayback:
                        self?.dispatch?(.playbackFinished)
                    case .didChangeLoadedTimeRanges(let new):
                        guard let end = new.last?.end else { return }
                        self?.dispatch?(.bufferedTimeUpdated(end))
                    case .didReceivePlayerError(let error):
                        self?.dispatch?(.playbackFailed(error))
                    default: break
                    }
                }
                
                player = currentPlayer
                
                seekerController = SeekerController(with: currentPlayer, context: props.context) { [weak self] event in
                    guard let dispatch = self?.dispatch else { return }
                    switch event {
                    case .startSeek: dispatch(.didStartSeek)
                    case .stopSeek: dispatch(.didStopSeek)
                    }
                }
                
                let pixelBufferAttributes = [
                    kCVPixelBufferPixelFormatTypeKey as String :
                        NSNumber(value: kCVPixelFormatType_32BGRA),
                    kCVPixelBufferWidthKey as String : 1024,
                    kCVPixelBufferHeightKey as String : 512
                ]
                
                let videoOutput =
                    AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)
                currentPlayer.currentItem?.add(videoOutput)
                output = videoOutput
            }
            
            sphereview?.camera.pitch = .init(props.angles.vertical)
            sphereview?.camera.yaw = .init(props.angles.horizontal)
            
            guard currentPlayer.currentItem?.status == .readyToPlay else { return }
            
            func newDuration() -> CMTime? {
                guard props.hasDuration == false, let item = currentPlayer.currentItem else { return nil }
                
                guard case .loaded = item.asset.statusOfValue(forKey: "duration", error: nil) else {
                    //TODO: this should be reported to telemetry
                    return nil
                }
                guard !CMTIME_IS_INDEFINITE(item.asset.duration) else { return nil }
                return item.asset.duration
            }
            if let duration = newDuration() {
                dispatch?(.durationReceived(duration))
                return
            }
            
            seekerController?.process(to: props.currentTime)
            
            if timeObserver == nil {
                timeObserver = currentPlayer.addPeriodicTimeObserver(
                    forInterval: CMTime(seconds: 0.2, preferredTimescale: 600),
                    queue: nil,
                    using: { [weak self] time in
                        self?.seekerController?.currentTime = time
                        self?.dispatch?(.currentTimeUpdated(time))
                })
            }
            
            currentPlayer.allowsExternalPlayback = false
            
            currentPlayer.isMuted = props.isMuted
            
            if currentPlayer.rate != props.rate {
                currentPlayer.rate = props.rate
            }
            
            sphereview?.setNeedsDisplay()
        }
    }
}
