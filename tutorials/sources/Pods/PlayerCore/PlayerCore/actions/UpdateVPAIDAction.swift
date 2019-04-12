//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreMedia

enum VPAIDActions {
    struct AdDurationChange: Action {
        let duration: CMTime
    }
    struct AdCurrentTimeChanged: Action {
        let newTime: CMTime
    }
    struct AdClickThru: Action {
        let url: String?
    }
    struct AdWindowOpen: Action {
        let url: URL
    }
    struct AdError: Action {
        let error: Error
    }
    struct AdVolumeChange: Action {
        let volume: Float
    }
    struct AdUniqueEventAbuse: Action {
        let name: String
        let value: String?
    }
    struct AdJavaScriptEvaluationError: Action {
        let error: Error
    }
    
    struct AdLoaded: Action {}
    struct AdNotSupported: Action {}
    struct AdStarted: Action {}
    struct AdStopped: Action {}
    struct AdSkipped: Action {}
    struct AdPaused: Action {}
    struct AdResumed: Action {}
    struct AdImpression: Action {}
    struct AdVideoStart: Action {}
    struct AdVideoFirstQuartile: Action {}
    struct AdVideoMidpoint: Action {}
    struct AdVideoThirdQuartile: Action {}
    struct AdVideoComplete: Action {}
    struct AdUserAcceptInvitation: Action {}
    struct AdUserMinimize: Action {}
    struct AdUserClose: Action {}
    struct AdScriptLoaded: Action {}
}
