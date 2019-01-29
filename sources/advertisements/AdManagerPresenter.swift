//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import PlayerCore

struct AdManagerActions<Result> {
    var skipPreroll = nop() as Action<UUID>
    var startPreroll = nop() as Action<Result>
}

final class AdManager<Result> {
    let requestAd: (URL) -> Future<Result?>
    let dispatcher: (PlayerCore.Action) -> ()
    
    init(requestAd: @escaping (URL) -> Future<Result?>,
         dispatcher: @escaping (PlayerCore.Action) -> ()) {
        self.requestAd = requestAd
        self.dispatcher = dispatcher
    }
    
    typealias Actions = AdManagerActions<Result>
    var actions = Actions()
    
    var state = (
        isLoading: false,
        isLoaded: false
    )

    var props = (
        preroll: (
            number: 0,
            count: 0
        ),
        sessionID: nil as UUID?,
        url: nil as URL?,
        isStarted: false) {
        didSet(old) {
            precondition(!(old.isStarted == true && props.isStarted == false))
            
            guard props.isStarted else { return }
            
            if old.sessionID != props.sessionID {
                state.isLoaded = false
                state.isLoading = false
            }
            
            if old.preroll.number != props.preroll.number {
                state.isLoaded = false
            }
            
            guard props.preroll.number < props.preroll.count else { return }
            guard !state.isLoading else { return }
            guard !state.isLoaded else { return }
            guard let sessionID = props.sessionID else { return }
            guard let url = props.url else { return }
            
            state.isLoading = true
            
            let id = UUID()
            dispatcher(PlayerCore.adRequest(url: url, id: id, type: .preroll))
            requestAd(url).onComplete { result in
                guard sessionID == self.props.sessionID else { return }
                self.state.isLoading = false
                self.state.isLoaded = true
                if let model = result {
                    self.actions.startPreroll(model)
                } else {
                    self.actions.skipPreroll(id)
                }
            }
        }
    }
}
