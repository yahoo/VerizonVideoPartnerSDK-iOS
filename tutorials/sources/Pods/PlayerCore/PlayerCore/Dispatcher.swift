//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

struct Dispatcher {
    private let _dispatch: (Action) -> ()
    
    init(dispatch: @escaping (Action) -> ()) {
        _dispatch = dispatch
    }
    
    func dispatch(action: Action) { _dispatch(action) }
}
