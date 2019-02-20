//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

struct ShowAd: Action {
    let creative: AdCreative
    let id: UUID
    let adVerifications: [Ad.VASTModel.AdVerification]
}

struct ShowMP4Ad: Action {
    let creative: AdCreative.MP4
    let id: UUID
}

struct ShowVPAIDAd: Action {
    let creative: AdCreative.VPAID
    let id: UUID
}
