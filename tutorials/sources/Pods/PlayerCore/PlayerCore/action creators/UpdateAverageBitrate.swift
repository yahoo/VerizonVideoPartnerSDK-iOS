//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.


public func updateContent(averageBitrate: Double) -> Action {
    return UpdateContentAverageBitrate(bitrate: averageBitrate)
}

public func updateAd(averageBitrate: Double) -> Action {
    return UpdateAdAverageBitrate(bitrate: averageBitrate)
}
