//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import PlayerCore

final class Store {
    var props: Player.Properties {
        return Player.Properties(state: state.value, model: model)
    }
    var channel: Telemetry.Channel!
    
    let model: PlayerCore.Model
    var state: Observable<PlayerCore.State>
    private let queue: DispatchQueue
    
    required init(model: PlayerCore.Model, queue: DispatchQueue) {
        self.model = model
        self.queue = queue
        let hasPrerollAds: Bool = perform {
            guard let available = model.playlist[0].available else { return false }
            return available.ad.preroll.count > 0
        }

        self.state = Observable(value: State(isPlaybackInitiated: model.isAutoplayEnabled,
                                             hasPrerollAds: hasPrerollAds,
                                             midrolls: model.midrolls[0],
                                             timeoutBarrier: model.adSettings.hardTimeout,
                                             maxAdDuration: model.adSettings.maxDuration,
                                             isOpenMeasurementEnabled: model.isOpenMeasurementAllowed),
                                queue: queue)
        self.channel = Telemetry.Station.shared.makeChannel(for: self)
    }
    
    func dispatch(action: PlayerCore.Action, type: DispatchType = .async) {
        let reduce = { self.reduce(action: action) }
        switch type {
        case .async: queue.async(execute: reduce)
        case .sync: queue.sync(execute: reduce)
        }
    }
    
    func addObserver(with model: PlayerCore.Model,
                     on queue: DispatchQueue = .main,
                     mode: ObservationMode = .throttleUpdates,
                     _ observer: @escaping (PlayerCore.State, PlayerCore.Model) -> Void) -> () -> Void {
        return state.addObserver(on: queue, mode: mode) { observer($0, model) }
    }
    
    func reduce(action: PlayerCore.Action) {
        state.value = PlayerCore.reduce(state: state.value, action: action)
    }
}
