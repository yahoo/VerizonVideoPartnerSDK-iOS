//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
public struct State {
    public let playlist: Playlist
    public let rate: Rate
    public let duration: Duration
    public let ad: Ad
    public let adKill: AdKill
    public let adMaxShowTime: TimerSession
    public let openMeasurement: OpenMeasurement
    public let serviceScript: OpenMeasurementServiceScript
    public let currentTime: CurrentTime
    public let loadedTimeRanges: LoadedTimeRanges
    public let playbackStatus: PlaybackStatus
    public let interactiveSeeking: InteractiveSeeking
    public let viewport: Viewport
    public let mute: Mute
    public let pictureInPicture: PictureInPicture
    public let airPlay: AirPlay
    public let clickthrough: AdClickthrough
    public let playerSession: PlayerSession
    public let playbackSession: PlaybackSession
    public let playbackDuration: PlaybackDuration
    public let playbackBuffering: PlaybackBuffering
    public let averageBitrate: AverageBitrate
    public let adTracker: AdFinishTracker
    public let adVRMManager: AdVRMManager
    public let mediaOptions: MediaOptions
    public let adInfoHolder: AdInfoHolder?
    public let transactionIDHolder: TransactionIDHolder?
    public let contentFullScreen: ContentFullScreen
    public let userActions: UserActions
    public let vpaid: VPAIDState
    public let vpaidErrors: VPAIDErrors
    public let vrmRequestStatus: VRMRequestStatus
    public let vrmResponse: VRMResponse?
    public let vrmGroupsQueue: VRMGroupsQueue
    public let vrmCurrentGroup: VRMCurrentGroup
    public let vrmTopPriorityItem: VRMTopPriorityItem
    public let vrmScheduledItems: ScheduledVRMItems
    public let vrmFetchItemsQueue: VRMFetchItemQueue
    public let vrmParseItemsQueue: VRMParseItemQueue
    public let vrmParsingResult: VRMParsingResult
}


import Foundation
import CoreMedia

extension State {
    public init(playerId: UUID = UUID(),
                playbackID: UUID = UUID(),
                creationDate: Date = Date(),
                isPlaybackInitiated: Bool,
                hasPrerollAds: Bool,
                midrolls: [Midroll],
                timeoutBarrier: Double,
                maxAdDuration: Int) {
        self = State(
            playlist: Playlist(currentIndex: 0),
            rate: Rate(contentRate: Rate.Value(player: isPlaybackInitiated, stream: false),
                       adRate: Rate.Value(player: false, stream: false),
                       isAttachedToViewPort: false,
                       currentKind: .content),
            duration: Duration(ad: nil, content: nil),
            ad: Ad(playedAds: [],
                   midrolls: midrolls.map { .init(cuePoint: $0.cuePoint, url: $0.url, id: UUID()) },
                   adCreative: .none,
                   currentAd: .empty,
                   currentType: hasPrerollAds ? .preroll : .midroll),
            adKill: .none,
            adMaxShowTime: .init(state: .stopped,
                                 startAdSession: nil,
                                 allowedDuration: Double(maxAdDuration)),
            openMeasurement: OpenMeasurement.inactive,
            serviceScript: OpenMeasurementServiceScript.none,
            currentTime: CurrentTime(content: nil, ad: CMTime.zero),
            loadedTimeRanges: LoadedTimeRanges(content: [] as [CMTimeRange], ad: [] as [CMTimeRange]),
            playbackStatus: PlaybackStatus(content: .unknown, ad: .unknown),
            interactiveSeeking: InteractiveSeeking(isSeekingInProgress: false),
            viewport: Viewport(dimensions: nil, camera: .init(horizontal: 0, vertical: 0)),
            mute: Mute(player: false, vpaid: false),
            pictureInPicture: .unsupported,
            airPlay: .restricted,
            clickthrough: AdClickthrough(isPresentationRequested: false),
            playerSession: PlayerSession(id: playerId,
                                         creationTime: creationDate,
                                         isCompleted: false,
                                         isStarted: isPlaybackInitiated),
            playbackSession: PlaybackSession(
                id: playbackID,
                intentTime: nil,
                startTime: nil,
                isCompleted: false),
            playbackDuration: PlaybackDuration(startTime: nil, duration: 0),
            playbackBuffering: PlaybackBuffering(content: .unknown, ad: .unknown),
            averageBitrate: AverageBitrate(content: 0, ad: 0),
            adTracker: AdFinishTracker(isFinished: false),
            adVRMManager: AdVRMManager(timeoutBarrier: Int(timeoutBarrier * 1000),
                                       requestsFired: 0,
                                       request: .initial()),
            mediaOptions: .empty,
            adInfoHolder: nil,
            transactionIDHolder: nil,
            contentFullScreen: .inactive,
            userActions: .nothing,
            vpaid: VPAIDState(events: [],
                              adClickthrough: nil),
            vpaidErrors: VPAIDErrors(abusedEvents: [],
                                     javaScriptEvaluationErrors: [],
                                     isAdNotSupported: false),
            vrmRequestStatus: .initial,
            vrmResponse: nil,
            vrmGroupsQueue: .initial,
            vrmCurrentGroup: .initial,
            vrmTopPriorityItem: .initial,
            vrmScheduledItems: .initial,
            vrmFetchItemsQueue: .initial,
            vrmParseItemsQueue: .initial,
            vrmParsingResult: .initial
        )
    }
}

public func reduce(state: State, action: Action) -> State {
    return State(
        playlist: reduce(state: state.playlist, action: action),
        rate: reduce(state: state.rate, action: action),
        duration: reduce(state: state.duration, action: action),
        ad: reduce(state: state.ad, action: action),
        adKill: reduce(state: state.adKill, action: action),
        adMaxShowTime: reduce(state: state.adMaxShowTime, action: action),
        openMeasurement: reduce(state: state.openMeasurement, action: action),
        serviceScript: reduce(state: state.serviceScript, action: action),
        currentTime: reduce(state: state.currentTime, action: action),
        loadedTimeRanges: reduce(state: state.loadedTimeRanges, action: action),
        playbackStatus: reduce(state: state.playbackStatus, action: action),
        interactiveSeeking: reduce(state: state.interactiveSeeking, action: action),
        viewport: reduce(state: state.viewport, action: action),
        mute: reduce(state: state.mute, action: action),
        pictureInPicture: reduce(state: state.pictureInPicture, action: action),
        airPlay: reduce(state: state.airPlay, action: action),
        clickthrough: reduce(state: state.clickthrough, action: action),
        playerSession: reduce(state: state.playerSession, action: action),
        playbackSession: reduce(state: state.playbackSession, action: action),
        playbackDuration: reduce(state: state.playbackDuration, action: action),
        playbackBuffering: reduce(state: state.playbackBuffering, action: action),
        averageBitrate: reduce(state: state.averageBitrate, action: action),
        adTracker: reduce(state: state.adTracker, action: action),
        adVRMManager: reduce(state: state.adVRMManager, action: action),
        mediaOptions: reduce(state: state.mediaOptions, action: action),
        adInfoHolder: reduce(state: state.adInfoHolder, action: action),
        transactionIDHolder: reduce(state: state.transactionIDHolder, action: action),
        contentFullScreen: reduce(state: state.contentFullScreen, action: action),
        userActions: reduce(state: state.userActions, action: action),
        vpaid: reduce(state: state.vpaid, action: action),
        vpaidErrors: reduce(state: state.vpaidErrors, action: action),
        vrmRequestStatus: reduce(state: state.vrmRequestStatus, action: action),
        vrmResponse: reduce(state: state.vrmResponse, action: action),
        vrmGroupsQueue: reduce(state: state.vrmGroupsQueue, action: action),
        vrmCurrentGroup: reduce(state: state.vrmCurrentGroup, action: action),
        vrmTopPriorityItem: reduce(state: state.vrmTopPriorityItem, action: action),
        vrmScheduledItems: reduce(state: state.vrmScheduledItems, action: action),
        vrmFetchItemsQueue: reduce(state: state.vrmFetchItemsQueue, action: action),
        vrmParseItemsQueue: reduce(state: state.vrmParseItemsQueue, action: action),
        vrmParsingResult: reduce(state: state.vrmParsingResult, action: action)
    )
}
