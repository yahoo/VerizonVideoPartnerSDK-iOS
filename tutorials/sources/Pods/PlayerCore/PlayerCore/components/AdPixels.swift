//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.


import Foundation

public struct AdPixels: Equatable {
    public typealias URLs = [URL]
    public var impression: URLs
    public var error: URLs
    public var clickTracking: URLs
    public var creativeView: URLs
    public var start: URLs
    public var firstQuartile: URLs
    public var midpoint: URLs
    public var thirdQuartile: URLs
    public var complete: URLs
    public var pause: URLs
    public var resume: URLs
    public var skip: URLs
    public var mute: URLs
    public var unmute: URLs
    public var acceptInvitation: URLs
    public var acceptInvitationLinear: URLs
    public var close: URLs
    public var closeLinear: URLs
    public var collapse: URLs
    
    public init(impression: URLs = [],
                error: URLs = [],
                clickTracking: URLs = [],
                creativeView: URLs = [],
                start: URLs = [],
                firstQuartile: URLs = [],
                midpoint: URLs = [],
                thirdQuartile: URLs = [],
                complete: URLs = [],
                pause: URLs = [],
                resume: URLs = [],
                skip: URLs = [],
                mute: URLs = [],
                unmute: URLs = [],
                acceptInvitation: URLs = [],
                acceptInvitationLinear: URLs = [],
                close: URLs = [],
                closeLinear: URLs = [],
                collapse: URLs = []) {
        self.impression = impression
        self.error = error
        self.clickTracking = clickTracking
        self.creativeView = creativeView
        self.start = start
        self.firstQuartile = firstQuartile
        self.midpoint = midpoint
        self.thirdQuartile = thirdQuartile
        self.complete = complete
        self.pause = pause
        self.resume = resume
        self.skip = skip
        self.mute = mute
        self.unmute = unmute
        self.acceptInvitation = acceptInvitation
        self.acceptInvitationLinear = acceptInvitationLinear
        self.close = close
        self.closeLinear = closeLinear
        self.collapse = collapse
    }
}
