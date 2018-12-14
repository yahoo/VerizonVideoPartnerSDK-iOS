//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

class VideoContextPresenter {
    
    enum Input {
        case notStarted
        case adLoading
        case ad
        case content
    }
    
    enum Output {
        case empty
        case ad
        case content
    }
    
    var lastInput: Input?
    var lastOutput: Output?
    
    func process(_ input: Input) -> Output {
        
        let result: Output
        
        switch (lastOutput, lastInput, input) {
        case (_, nil, .adLoading): result = .empty
        case (_, .some(.content), .adLoading): result = .empty
        case (nil, nil, .notStarted): result = .content
        case (_, _, .content): result = .content
        case (_, _, .ad): result = .ad
        
        case let(.some(last), _, _): result = last
        default: fatalError("Uncomplete list of options") }
        
        lastOutput = result
        lastInput = input
        return result
    }
}

extension VideoContextPresenter {
    func process(_ props: Player.Properties) -> Output {
        func input(_ props: Player.Properties) -> VideoContextPresenter.Input {
            guard props.isPlaybackInitiated else { return .notStarted }
            guard let item = props.playbackItem else { return .content }
            guard item.hasActiveAds else { return .content }
            guard item.isAdPlaying else { return .adLoading }
            return .ad
        }
        return process(input(props))
    }
}
