//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

public struct AdVASTProgress {
    public let pixels: [Pixel]
    
    public struct Pixel {
        public let url: URL
        public let offsetInSeconds: Int
    }
}

func reduce(state: AdVASTProgress, action: Action) -> AdVASTProgress {
    switch action {
    case is VRMCore.AdRequest:
        return AdVASTProgress(pixels: [])
    case let action as UpdateAdDuration:
        guard let duration = action.newDuration else { return state }
        return AdVASTProgress(pixels: action.vastAdProgress.compactMap {
            var offsetInSeconds: Int?
            switch $0.offset {
            case .time(let offset):
                offsetInSeconds = offset
            case .percentage(let percent):
                offsetInSeconds = Int(duration.seconds.rounded() / 100 * Double(percent))
            }
            guard let offset = offsetInSeconds else { return nil }
            return AdVASTProgress.Pixel(url: $0.url, offsetInSeconds: offset)
        })
    default: return state
    }
}
