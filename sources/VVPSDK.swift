//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import AVKit
import PlayerCore
// Added import only for testing purposes
#if os(iOS)
import OMSDK_Oath2
#endif
/// Glue code for connecting all parts of an SDK.
/// It contains some configuration details for other components.
public struct VVPSDK {
    private let configuration: Configuration
    
    public let videoProvider: VideoProvider
    private let vrmProvider: VRMProvider
    
    private let ephemeralSession: URLSession
    private static let defaultSession = URLSession(configuration: .default)
    private var telemetryMetrics: Telemetry.Metrics?
    
    /// Initialiser for VVPSDK struct.
    ///
    /// - parameter configuration: Describe fields and behaviors of an SDK instance
    /// - returns: VVPSDK struct.
    public init(configuration: Configuration) {
        self.configuration = configuration
        /* setup ephemeral session */ do {
            let ephemeral = URLSessionConfiguration.ephemeral
            ephemeral.httpAdditionalHeaders = ["User-Agent" : configuration.userAgent]
            ephemeralSession = URLSession(configuration: ephemeral)
        }
        
        /* setup video provider */ do {
            func trackingType(for tracking: Configuration.Tracking) -> VideoProvider.TrackingType {
                switch tracking {
                case .native: return .native
                case .javascript: return .javascript
                }
            }
            
            self.videoProvider = VideoProvider(
                session: ephemeralSession,
                url: configuration.video.url,
                context: configuration.video.context,
                trackingType: configuration.tracking |> trackingType)
        }
        
        /* setup vrm provider */ do {
            self.vrmProvider = VRMProvider(session: ephemeralSession)
        }
        
        /* attach ad url process listener */ do {
            if let url = configuration.telemetry?.url {
                let listener = Telemetry.Listeners.AdURLProcessListener.shared
                
                listener.session = ephemeralSession
                listener.url = url
                
                Telemetry.Station.shared.add(
                    listener: Telemetry.Listeners.AdURLProcessListener.shared
                )
            }
        }
        
        telemetryMetrics = configuration
            .telemetry
            .flatMap { config in
                Telemetry.Metrics(url: config.url,
                                  context: config.context,
                                  ephemeralSession: self.ephemeralSession)
        }
    }
    
    /// You can add and remove plugins to SDK.
    /// Plugin is a generalized observer for any player created by an SDK instance.
    public var plugins = Plugins()
    
    /// Build a player from a single video from certain company.
    /// Player model will be created with `autoplay = true`.
    /// You can override this setting by passing `false` for autoplay parameter.
    
    public func getPlayer(videoID: String,
                          autoplay: Bool = true,
                          siteSection: String = "") -> Future<Result<Player>> {
        return getPlayer(withVideoIDs: [videoID],
                         autoplay: autoplay,
                         siteSection: siteSection)
    }
    
    /// Build a player from playlist. Empty playlist will cause a parsing error.
    /// Player model will be created with `autoplay = true`.
    /// You can override this setting by passing `false` for autoplay parameter.
    ///
    ///   Usage like this is expected:
    ///   ```
    ///   func showPlayer(playerResult: () throws -> Player) {
    ///       // Handle result from `try playerResult()` call
    ///   }
    ///
    ///   sdk.getPlayer(playlistID: ...).withCallback(showPlayer)
    ///   ```
    ///
    /// - returns: Async code helper.
    @available(tvOS, unavailable, message: "VerizonVideoPartnerSDK currently supports only single video playback")
    public func getPlayer(playlistID: String,
                          autoplay: Bool = true,
                          siteSection: String = "") -> Future<Result<Player>> {
        return videoProvider.getVideosBy(playlistID: playlistID,
                                         siteSection: siteSection,
                                         autoplay: autoplay)
            .map { ($0, playlistID, siteSection) }
            .map(makePlayer)
            .onError { self.telemetryMetrics?.process(videoProviderError: $0) }
    }
    
    /// Build a player from an array of video ids.
    /// You have to pass at least one video id.
    /// Empty playlist will cause a parsing error.
    /// Player model will be created with `autoplay = true`.
    /// You can override this setting by passing `false` for autoplay parameter.
    ///
    ///   Usage like this is expected:
    ///   ```
    ///   func showPlayer(playerResult: () throws -> Player) {
    ///       // Handle result from `try playerResult()` call
    ///   }
    ///
    ///   sdk.getPlayer(videoIDs: ...).withCallback(showPlayer)
    ///   ```
    ///
    /// - returns: Async code helper.
    @available(tvOS, unavailable, message: "tvOS SDK currently supports only single video playback")
    public func getPlayer(videoIDs: [String],
                          autoplay: Bool = true,
                          siteSection: String = "") -> Future<Result<Player>> {
        return getPlayer(withVideoIDs: videoIDs,
                         autoplay: autoplay,
                         siteSection: siteSection)
    }
    
    /// This function is responsible for synchronous creation of player
    /// and binding it with advertisement and metrics components.
    ///
    /// - parameter videoResponse: An array of video response objects.
    ///   Usually received from `videosForVideoIDs(videoIDs:)`
    ///   this function.
    /// - parameter autoplay:      Should player autoplay first video or not.
    ///
    /// - returns: `Player` instance.
    public func makePlayer(videoResponse: VideoProvider.Response,
                           playlistId: String? = nil,
                           siteSection: String = "") -> Player {
        
        let videoModels: [PlayerCore.Model.Video] = videoResponse.videos.map {
            switch $0 {
            case .video(let video):
                func ads(from pods: [VideoProvider.Response.Pod]) -> PlayerCore.Model.Video.Item.AdModel {
                    return PlayerCore.Model.Video.Item.AdModel(
                        preroll: perform {
                            return pods
                                .filter {
                                    guard case .preroll = $0.time else { return false }
                                    return true
                                }.map { .init(url: $0.url) }
                        },
                        midroll: pods.compactMap { pod -> PlayerCore.Model.Video.Item.AdModel.Midroll? in
                            guard case .seconds(let time) = pod.time else { return nil }
                            return .init(cuePoint: time, url: pod.url)
                    })
                }
                
                func isPictureInPictureSupported() -> Bool {
                    guard video.isPictureInPictureEnabled else { return false }
                    
                    #if os(iOS)
                    if #available(iOS 9, *) {
                        return AVPictureInPictureController.isPictureInPictureSupported()
                    }
                    #endif
                    return false
                }
                
                func brandedContent() -> PlayerCore.Model.Video.Item.BrandedContent? {
                    typealias BrandedContent = PlayerCore.Model.Video.Item.BrandedContent
                    guard let model = video.brandedContent else { return nil }
                    
                    func tracker() -> BrandedContent.Tracker? {
                        guard let responseTracker = model.tracker else { return nil }
                        return .init(impression: responseTracker.impression,
                                     view: responseTracker.view,
                                     click: responseTracker.click,
                                     quartile1: responseTracker.quartile1,
                                     quartile2: responseTracker.quartile2,
                                     quartile3: responseTracker.quartile3,
                                     quartile4: responseTracker.quartile4)
                    }
                    
                    return BrandedContent(advertisementText: model.advertisementText,
                                          clickUrl: model.clickUrl,
                                          tracker: tracker())
                }
                
                func thumbnail() -> PlayerCore.Model.Video.Thumbnail? {
                    let videoThumbnails = video.thumbnails.map {
                        PlayerCore.Thumbnail(width: $0.width, height: $0.height, url: $0.url)
                    }
                    return PlayerCore.Model.Video.Thumbnail(items: videoThumbnails)
                }
                
                return PlayerCore.Model.Video.available(.init(
                    url: video.url,
                    renderer: PlayerCore.Descriptor(id: video.renderer.id,
                                                    version: video.renderer.version),
                    ad: ads(from: video.pods),
                    isAirPlayEnabled: video.isScreenCastingEnabled,
                    isPictureInPictureModeSupported: isPictureInPictureSupported(),
                    brandedContent: brandedContent(),
                    title: video.title,
                    thumbnail: thumbnail()))
            case .invalid(let reason),
                 .missing(let reason),
                 .restricted(let reason):
                return PlayerCore.Model.Video.unavailable(reason)
            case .missingRenderer(let renderer):
                return PlayerCore.Model.Video.unavailable("Missing renderer with ID: \(renderer.id), version: \(renderer.version)")
            }
        }
        
        let videoIds: [VideoId] = videoResponse.videos.map {
            guard case .video(let video) = $0 else { return VideoId.unavailable() }
            return .init(videoId: video.id)
        }
        
        let adSettings = PlayerCore.Model.AdSettings(
            prefetchingOffset: videoResponse.adSettings.prefetchingOffset,
            softTimeout: videoResponse.adSettings.softTimeout,
            hardTimeout: videoResponse.adSettings.hardTimeout,
            startTimeout: videoResponse.adSettings.startTimeout,
            maxSearchTime: videoResponse.adSettings.maxSearchTime,
            maxDuration: videoResponse.adSettings.maxDuration,
            maxVASTWrapperRedirectCount: videoResponse.adSettings.maxVASTWrapperRedirectCount)
        
        let vpaidSettings = PlayerCore.Model.VPAIDSettings(document: self.configuration.vpaid.document)
        let omSettings = PlayerCore.Model.OMSettings(serviceScriptURL: self.configuration.openMeasurement.script)
        
        let playerModel = PlayerCore.Model(playlist: videoModels,
                                           autoplay: videoResponse.autoplay,
                                           controlsAnimationSupported: videoResponse.features.isControlsAnimationEnabled,
                                           isVPAIDAllowed: videoResponse.features.isVPAIDAllowed,
                                           isOpenMeasurementAllowed: videoResponse.features.isOpenMeasurementEnabled,
                                           isFailoverEnabled: videoResponse.features.isFailoverEnabled,
                                           adSettings: adSettings,
                                           vpaidSettings: vpaidSettings,
                                           omSettings: omSettings)
        
        let player = Player(model: playerModel)
        
        switch (videoResponse.tracking, configuration.tracking) {
        case (.native(let native), .native):
            let reporterTracer = player.tracer.map(ReporterTracer.init)
            let sendMetric = MetricsSender.URLSender(
                session: ephemeralSession,
                advertisementBaseURL: native.adURL,
                trackingBaseURL: native.trkURL,
                trace: {
                    reporterTracer?.record(url: $0)
                    reporterTracer?.completeItem()
            })
            
            let reporterContext = TrackingPixels.Reporter.Context(
                playerID: native.pid,
                applicationID: native.appID,
                buyingCompanyID: native.bcid,
                videoObjectIDs: native.videoIds,
                playlistID: native.playlistId,
                playerVersion: native.playerVersion,
                playerType: native.playerType,
                sessionID: native.sessionId,
                uuid: native.uuid,
                siteSection: native.siteSection.nonEmpty,
                platformSupport: native.platformSupport,
                referringURL: native.referringURLString,
                vcdn: native.vcdn,
                apid: native.apid,
                mpid: native.mpid,
                vcid: native.vcid
            )
            
            let reporter = TrackingPixels.Reporter(
                context: reporterContext,
                sendMetric: sendMetric.send,
                cachebuster: {
                    let cb = String(Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max))
                    reporterTracer?.record(cachebuster: cb)
                    return cb }
            )
            reporter.impression()
            
            let connector = TrackingPixels.Connector(reporter: reporter)
            _ = player.addObserver(connector.process)
            _ = player.store.addObserver(with: playerModel, mode: .everyUpdate, connector.process)
            
        case (.javascript(let context), .javascript(let javascript)):
            func send(url: URL) {
                ephemeralSession.dataTask(with: url).resume()
            }
            
            let jsTelemetry = JavaScriptTelemetry(
                session: ephemeralSession,
                url: javascript.telemetry.url,
                context: javascript.telemetry.context)
            
            let jsAnalytics = AnalyticsObserver(context: context,
                                                jsSourceUrl: javascript.source,
                                                session: VVPSDK.defaultSession,
                                                send: send,
                                                report: jsTelemetry.send)
            _ = player.addObserver(jsAnalytics.process)
        default:
            fatalError("Internal logic error - unexpected mix of \(videoResponse.tracking) and \(configuration.tracking)")
        }
        
        bindAd(to: player)
        
        // attach telemetry on player props changes
        if let telemetryMetrics = telemetryMetrics {
            _ = player.addObserver(telemetryMetrics.process)
            _ = player.store.addObserver(with: playerModel, telemetryMetrics.process)
        }
        
        plugins.bindTo(player: player, ids: videoIds, siteSection: siteSection)
        
        return player
    }
    
    private func getPlayer(withVideoIDs videoIDs: [String],
                           autoplay: Bool = true,
                           siteSection: String = "") -> Future<Result<Player>> {
        precondition(videoIDs.count > 0)
        
        return videoProvider.getVideosBy(videoIDs: videoIDs,
                                         siteSection: siteSection,
                                         autoplay: autoplay)
            .map { ($0, nil, siteSection) }
            .map(makePlayer)
            .onError { self.telemetryMetrics?.process(videoProviderError: $0) }
    }
    
    private func bindAd(to player: Player) {
        let dispatcher: (PlayerCore.Action) -> Void = { [weak player] in player?.store.dispatch(action: $0) }
        let softTimeout = player.model.adSettings.softTimeout
        let hardTimeout = player.model.adSettings.hardTimeout
        let isVPAIDAllowed = player.model.isVPAIDAllowed
        let maxRedirectCount = player.model.adSettings.maxVASTWrapperRedirectCount
        let maxAdSearchTime = player.model.adSettings.maxSearchTime
        let createRequest: (URL) -> (URLRequest) = {
            .init(url: $0, timeoutInterval: hardTimeout)
        }
        
        let prerollProcessor = VRMPrerollProcessorController(dispatch: dispatcher)
        let midrollProcessor = VRMMidrollProcessorController(dispatch: dispatcher)
        let startGroupProcessing = StartVRMGroupProcessingController(dispatch: dispatcher)
        let finishGroupProcessing = FinishVRMGroupProcessingController(dispatch: dispatcher)
        let itemController = VRMItemController(dispatch: dispatcher)
        let itemFetchController = FetchVRMItemController(dispatch: dispatcher) { url in
            self.ephemeralSession.dataFuture(with: createRequest(url))
                .map(Network.Parse.successResponseData)
                .map(Network.Parse.string)
        }
        let itemParseController = ParseVRMItemController(dispatch: dispatcher,
                                                         vastMapper: vastMapper) { vastXML in
                                                            Future(value: vastXML).map(VASTParser.parseFrom)
        }
        let vrmRequestController = VRMRequestController(dispatch: dispatcher,
                                                        groupsMapper: mapGroups) { url in
                                                            self.vrmProvider.requestAds(with: createRequest(url))
        }
        let processingController = VRMProcessingController(maxRedirectCount: maxRedirectCount,
                                                           isVPAIDAllowed: isVPAIDAllowed,
                                                           dispatch: dispatcher)
        
        let timeoutController = VRMTimeoutController(dispatch: dispatcher,
                                                     softTimeoutTimerFactory: { onFire in
                                                        Timer(duration: softTimeout, fire: onFire) },
                                                     hardTimeoutTimerFactory: { onFire in
                                                        Timer(duration: hardTimeout, fire: onFire) })
        let isFailoverEnabled = player.model.isFailoverEnabled
        let selectFinalResult = VRMSelectFinalResultController(isFailoverEnabled: isFailoverEnabled, dispatch: dispatcher)
        let maxAdSearchTimeController = MaxAdSearchTimeController { requestID in
            Timer(duration: maxAdSearchTime) {
                dispatcher(PlayerCore.VRMCore.maxSearchTimeoutReached(requestID: requestID))
            }
        }
        
        let mp4AdCreativeController = MP4AdCreativeController(dispatch: dispatcher)
        let vpaidAdCreativeController = VPAIDAdCreativeController(dispatch: dispatcher)
        
        let maxAdDuration = player.model.adSettings.maxDuration
        let maxShowTimeController = MaxShowTimeController(timerCreator: { Timer(duration: $0){ dispatcher(maxShowTimeReached())} },
                                                          maxAdDuration: maxAdDuration,
                                                          dispatcher: dispatcher)
        let adStartTimeout = player.model.adSettings.startTimeout
        let adStartTimeoutController = AdStartTimeoutController(dispatcher: dispatcher) { onFire in
            Timer(duration: adStartTimeout, fire: onFire)
        }
        
        _ = player.store.state.addObserver { state in
            vrmRequestController.process(with: state)
            startGroupProcessing.process(with: state)
            finishGroupProcessing.process(with: state)
            itemController.process(with: state)
            itemFetchController.process(with: state)
            itemParseController.process(with: state)
            processingController.process(with: state)
            timeoutController.process(with: state)
            selectFinalResult.process(with: state)
            maxAdSearchTimeController.process(with: state)
            mp4AdCreativeController.process(state: state)
            vpaidAdCreativeController.process(state: state)
            maxShowTimeController.process(state: state)
            adStartTimeoutController.process(state: state)
        }
        
        _ = player.addObserver { playerProps in
            prerollProcessor.process(props: playerProps)
            midrollProcessor.process(props: playerProps)
        }
    }
}

public struct VideoId {
    public let videoId: String?
    
    public init(videoId: String?) {
        self.videoId = videoId
    }
    
    public static func unavailable() -> VideoId {
        return VideoId(videoId: nil)
    }
}
