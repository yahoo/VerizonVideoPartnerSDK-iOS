//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
public struct Playlist {
    public let currentIndex: Int
}

func reduce(state: Playlist, action: Action) -> Playlist {
    switch action {
        
    case (let action as SelectVideoAtIdx):
        return Playlist(currentIndex: action.idx)
        
    default:
        return state
    }
}
