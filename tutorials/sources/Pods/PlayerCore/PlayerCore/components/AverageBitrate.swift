//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public struct AverageBitrate {
    public let content: Double?
    public let ad: Double?
}

func reduce(state: AverageBitrate, action: Action) -> AverageBitrate {
    switch action {
    case let content as UpdateContentAverageBitrate:
        return AverageBitrate(content: content.bitrate, ad: state.ad)
        
    case let ad as UpdateAdAverageBitrate:
        return AverageBitrate(content: state.content, ad: ad.bitrate)
    
    case is SelectVideoAtIdx:
        return AverageBitrate(content: nil, ad: nil)
        
    default:
        return state
    }    
}

