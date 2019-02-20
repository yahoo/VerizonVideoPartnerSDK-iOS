//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreMedia

public struct CurrentTime {
    public struct Content {
        public let time: CMTime
        public let isSeekInProgress: Bool
    }
    
    public let content: Content?
    public let ad: CMTime
}

func reduce(state: CurrentTime, action: Action) -> CurrentTime {
    switch (action, state.content) {
    case (let action as UpdateContentCurrentTime, _):
        if let content = state.content {
            guard content.isSeekInProgress == false else { return state }
            return CurrentTime(content: .init(time: action.newTime,
                                              isSeekInProgress: false),
                               ad: state.ad)
        } else {
            return CurrentTime(content: .init(time: action.newTime,
                                              isSeekInProgress: false),
                               ad: state.ad)
        }
        
    case (let action as UpdateAdCurrentTime, _):
        return CurrentTime(content: state.content, ad: action.newTime)
        
    case (let action as AdCurrentTimeChanged, _):
        return CurrentTime(content: state.content, ad: action.newTime)
        
    case (is DidStartSeeking, let content?):
        return CurrentTime(content: .init(time: content.time,
                                          isSeekInProgress: true),
                           ad: state.ad)
        
    case let (is DidStopSeeking, content?):
        return CurrentTime(content: .init(time: content.time,
                                          isSeekInProgress: false),
                           ad: state.ad)
        
    case let (action as SeekToTime, content?):
        return CurrentTime(content: .init(time: action.newTime,
                                          isSeekInProgress: content.isSeekInProgress),
                           ad: state.ad)
        
    case let (action as SeekToTime, nil):
        return CurrentTime(content: .init(time: action.newTime,
                                          isSeekInProgress: false),
                           ad: state.ad)
        
    case let (action as StartInteractiveSeeking, content?):
        return CurrentTime(content: .init(time: action.newTime,
                                          isSeekInProgress: content.isSeekInProgress),
                           ad: state.ad)
        
    case let (action as StopInteractiveSeeking, content?):
        return CurrentTime(content: .init(time: action.newTime,
                                          isSeekInProgress: content.isSeekInProgress),
                           ad: state.ad)
        
    case (is SelectVideoAtIdx, _):
        return CurrentTime(content: .init(time: CMTime.zero,
                                          isSeekInProgress: false),
                           ad: CMTime.zero)
        
    case (is ShowMP4Ad, _), (is ShowVPAIDAd, _), (is ShowAd, _):
        return CurrentTime(content: state.content, ad: CMTime.zero)
        
    default: return state
    }
}
