//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

func getMP4Creative(internalID: UUID = UUID(), width: Int, height: Int) -> AdCreative.MP4 {
    let testURL = URL(string: "https://")!
    return AdCreative.MP4(internalID: internalID,
                          url: testURL,
                          clickthrough: testURL,
                          pixels: AdPixels(),
                          id: "",
                          width: width,
                          height: height,
                          scalable: false,
                          maintainAspectRatio: true)
}

func getVPAIDCreative(internalID: UUID = UUID()) -> AdCreative.VPAID {
    let testURL = URL(string: "https://")!
    return AdCreative.VPAID(internalID: internalID,
                            url: testURL,
                            adParameters: "",
                            clickthrough: testURL,
                            pixels: AdPixels(),
                            id: "")
}
