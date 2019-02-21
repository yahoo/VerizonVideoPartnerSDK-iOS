//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreMedia

struct UpdateContentDuration: Action {
    let newDuration: CMTime?
}

struct UpdateAdDuration: Action {
    let newDuration: CMTime?
    let vastAdProgress: [Ad.VASTModel.AdProgress]
}
