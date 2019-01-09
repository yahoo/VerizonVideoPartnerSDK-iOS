//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import PlayerCore

/// This is object which can handle series of events and change state appropriately.
/// This object can be constructed with `PlayerCore.Model`.
public final class Player {
    var channel: Telemetry.Channel!
    
    let model: PlayerCore.Model
    let tracer: Tracer?
    let store: Store
    
    /// Construct new `Player` instance with given `PlayerCore.Model`
    public init(model: Model, tracer: Tracer? = nil) {
        self.tracer = tracer
        self.model = model
        let queue = DispatchQueue(label: "com.one.mobilesdk.player")
        self.store = Store(model: model, queue: queue)
        
        self.channel = Telemetry.Station.shared.makeChannel(for: self)
    }
    
    /// Current `Player.Properties` getter
    public var props: Properties {
        return store.props
    }
    
    /// Type of a regular state observer.
    /// This function will be called with `Player.State` argument
    /// when new state is arrived.
    public typealias PropsObserver = (Properties) -> ()
    
    /// Type of a state observation dispose token.
    /// To cancel observation - simple call resulting closure
    public typealias PropsObserverDispose = () -> ()

    /// Add observer (`Player.PropsObserver`) to a list of an observers,
    /// and fire current `Player.Properties` immediately.
    /// Observers are not tracked for uniquiness.
    /// As a result - Function of type `Player.PropsObserverDisposable`
    /// To cancel observation - just call resulting function
    public func addObserver(on queue: DispatchQueue = .main,
                            mode: ObservationMode = .throttleUpdates,
                            _ observer: @escaping PropsObserver) -> PropsObserverDispose {
        return store.addObserver(with: model, on: queue, mode: mode) { state, model in
            observer(Player.Properties(state: state, model: model))
        }
    }
    
    func dispatch(action: PlayerCore.Action, type: DispatchType = .async) {
        store.dispatch(action: action, type: type)
    }
    
    deinit {
        store.dispatch(action: PlayerCore.completePlayerSession(), type: .sync)
    }
}

enum DispatchType { case async, sync }
