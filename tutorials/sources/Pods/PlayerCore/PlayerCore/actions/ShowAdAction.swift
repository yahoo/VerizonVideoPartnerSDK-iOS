//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

struct ShowAd: Action {
    let creative: AdCreative
    let id: UUID
    let adVerifications: [Ad.VASTModel.AdVerification]
    let isOpenMeasurementEnabled: Bool
}
