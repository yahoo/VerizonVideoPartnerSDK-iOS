//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public func showMP4Ad(creative: AdCreative.MP4, id: UUID) -> Action {
    return ShowMP4Ad(creative: creative, id: id)
}
public func showVPAIDAd(creative: AdCreative.VPAID, id: UUID) -> Action {
    return ShowVPAIDAd(creative: creative, id: id)
}
