//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public enum ContentFullScreen {
    case inactive
    case active
}

func reduce(state: ContentFullScreen, action: Action) -> ContentFullScreen {
    switch action {
    case is ContentFullScreenToggleAction:
        switch state {
        case .inactive:
            return .active
        case .active:
            return .inactive
        }
    default: return state
    }
}
