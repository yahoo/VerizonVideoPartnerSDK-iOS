//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
@testable import VerizonVideoPartnerSDK

let tracer = Player.Tracer()

do {
    tracer.record(action: "play")
    tracer.record(action: "pause")
    tracer.record(action: "updateCurrentTime",
                  params: ["time" : 10 |> json])
    
    let actions = json(for: tracer.actions).object
    JSONSerialization.isValidJSONObject(actions)
    
    let data = try? JSONSerialization.data(
        withJSONObject: actions,
        options: .prettyPrinted)
    print(String(data: data!, encoding: .utf8)!)
}

do {
    let player = Player(model: Player.Model(videoURL: URL(string: "http://test.com")!),
                        tracer: tracer)

    tracer.record(props: player.props |> json)
    let props = (tracer.props |> json).object
    
    JSONSerialization.isValidJSONObject(props)
    let data = try? JSONSerialization.data(
        withJSONObject: props,
        options: .prettyPrinted)
    print(String(data: data!, encoding: .utf8)!)
}
