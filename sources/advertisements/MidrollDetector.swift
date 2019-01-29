//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

func prefetchAction(input: MidrollDetector.Input, lastPrefetchedMidroll: MidrollDetector.Midroll?, isPrefetchedModelEmpty: Bool) -> MidrollDetector.Action? {
    guard !input.hasActiveAds else { return nil }
    guard isPrefetchedModelEmpty else { return nil }
    
    let midrollsToPrefetch = input.midrolls.filter {
        let lastPrefetchedMidrollCuePoint = lastPrefetchedMidroll?.cuePoint ?? 0
        return input.currentTime > $0.cuePoint - input.prefetchingOffest
            && (input.currentTime < lastPrefetchedMidrollCuePoint && input.currentTime <= $0.cuePoint
                || $0.cuePoint > lastPrefetchedMidrollCuePoint)
    }
    
    var midroll: MidrollDetector.Midroll?
    
    if input.currentTime >= midrollsToPrefetch.last?.cuePoint ?? 0 {
        midroll = midrollsToPrefetch.last
    } else {
        midroll = midrollsToPrefetch.suffix(2).first
    }
    guard let midrollToPrefetch = midroll else { return nil }
    return .prefetch(midrollToPrefetch)
}

func playAction(input: MidrollDetector.Input,
          lastPrefetchedMidroll: MidrollDetector.Midroll?,
          prefetchedModel: PlayerCore.Ad.VASTModel?) -> MidrollDetector.Action? {
    guard let prefetchedMidroll = lastPrefetchedMidroll else { return nil }
    guard input.midrolls.contains(prefetchedMidroll) else { return nil }
    
    var midrollAfterSeek: MidrollDetector.Midroll? = prefetchedMidroll
    
    if input.currentTime > prefetchedMidroll.cuePoint {
        midrollAfterSeek = input.midrolls.min(by: { first, _ in first.cuePoint < input.currentTime })
    } else if input.currentTime < prefetchedMidroll.cuePoint {
        midrollAfterSeek = input.midrolls.max(by: { first, _ in first.cuePoint < input.currentTime })
    }
    
    guard let midrollToPlay = midrollAfterSeek else { return nil }
    guard input.currentTime >= midrollToPlay.cuePoint else { return nil }
    return .play(prefetchedModel, midrollToPlay)
}

class MidrollDetector {
    typealias Midroll = PlayerCore.Ad.Midroll
    
    enum Action: Hashable {
        case prefetch(Midroll)
        case play(PlayerCore.Ad.VASTModel?, Midroll)
    }
    
    struct Input {
        var midrolls: [Midroll]
        var prefetchingOffest: Int
        var currentTime: Int
        var isPlayMidrollAllowed: Bool
        var hasActiveAds: Bool
        var isVPAIDAllowed: Bool
        var isOpenMeasurementEnabled: Bool
    }
    
    struct State {
        var prefetchedModel: PlayerCore.Ad.VASTModel?
        var lastPrefetchedMidroll: Midroll?
        var isRequestingMidrollAd = false
        var prevAction: Action?
    }
    var state = State()
    
    let dispatcher: (PlayerCore.Action) -> Void
    let requestAd: (URL) -> Future<PlayerCore.Ad.VASTModel?>
    
    init(dispatcher: @escaping (PlayerCore.Action) -> Void,
         requestAd: @escaping (URL) -> Future<PlayerCore.Ad.VASTModel?>) {
        self.dispatcher = dispatcher
        self.requestAd = requestAd
    }
    
    func process(input: Input) {
        guard let action = action(input: input), action != state.prevAction else { return }
        state.prevAction = action
        
        switch action {
        case .prefetch(let midroll):
            state.lastPrefetchedMidroll = midroll
            state.isRequestingMidrollAd = true
            dispatcher(PlayerCore.adRequest(url: midroll.url, id: midroll.id, type: .midroll))
            requestAd(midroll.url).onComplete { [weak self] model in
                guard let `self` = self else { return }
                self.state.prefetchedModel = model
                self.state.isRequestingMidrollAd = false }
        case .play(let model, let midroll):
            state.lastPrefetchedMidroll = midroll
            state.prefetchedModel = nil
            guard let model = model else {
                dispatcher(PlayerCore.skipAd(id: midroll.id))
                return
            }
            dispatcher(PlayerCore.playAd(model: model,
                                         id: midroll.id,
                                         isOpenMeasurementEnabled: input.isOpenMeasurementEnabled))
        }
    }
    
    func action(input: Input) -> Action? {
        guard input.isPlayMidrollAllowed, !state.isRequestingMidrollAd else {
            return nil }
        
        let prefetch = prefetchAction(input: input,
                                      lastPrefetchedMidroll: state.lastPrefetchedMidroll,
                                      isPrefetchedModelEmpty: state.prefetchedModel == nil)
        let play = playAction(input: input,
                              lastPrefetchedMidroll: state.lastPrefetchedMidroll,
                              prefetchedModel: state.prefetchedModel)
        
        guard let action = prefetch ?? play else { return nil }
        return action
    }
}

extension MidrollDetector.Input {
    init?(playerProps: Player.Properties, isVPAIDAllowed: Bool, isOpenMeasurementEnabled: Bool) {
        guard let item = playerProps.playbackItem,
            let currentTime = item.content.time.static?.current else { return nil }
        
        self.isVPAIDAllowed = isVPAIDAllowed
        self.isOpenMeasurementEnabled = isOpenMeasurementEnabled
        self.currentTime = perform {
            guard currentTime > Double(Int.min) && currentTime < Double(Int.max) else { return 0 }
            return Int(currentTime) }
        prefetchingOffest = item.midrollPrefetchingOffset
        midrolls = item.midrolls
        isPlayMidrollAllowed = item.content.isPaused == false && item.content.isSeeking == false
        hasActiveAds = item.hasActiveAds
    }
}
