//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreMedia

public struct LoadedTimeRanges {
    public let content: [CMTimeRange]
    public let ad: [CMTimeRange]
}

func reduce(state: LoadedTimeRanges, action: Action) -> LoadedTimeRanges {
    switch action {
    case let action as UpdateContentLoadedTimeRanges:
        return LoadedTimeRanges(content: action.newValue, ad: state.ad)
        
    case let action as UpdateAdLoadedTimeRanges:
        return LoadedTimeRanges(content: state.content, ad: action.newValue)
        
    case is ShowContent:
        return LoadedTimeRanges(content: state.content, ad: state.ad)
        
    case is ShowMP4Ad, is ShowVPAIDAd, is ShowAd:
        return LoadedTimeRanges(content: state.content, ad: [])
        
    case is SelectVideoAtIdx:
        return LoadedTimeRanges(content: [], ad: [])
        
    default: return state
    }
}
