//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
public enum PictureInPicture {
    case unsupported
    case impossible
    case inactive
    case active
}

func reduce(state: PictureInPicture, action: Action) -> PictureInPicture {
    switch action {
    case let status as PictureInPictureStatusUpdate:
        guard status.isPossible else { return .impossible }
        guard state != .active else { return state }
        return .inactive
        
    case is PictureInPictureToggle:
        switch state {
        case .active: return .inactive
        case .inactive: return .active
        default: return state
        }
        
    default: return state
    }
}
