//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public func dropAd(id: UUID) -> Action {
    return DropAd(id: id)
}

