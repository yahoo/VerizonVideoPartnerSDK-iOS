//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

func getMP4Creative(width: Int, height: Int) -> AdCreative.MP4 {
    let testURL = URL(string: "https://")!
    return AdCreative.MP4(url: testURL,
                          clickthrough: testURL,
                          pixels: AdPixels(),
                          id: "",
                          width: width,
                          height: height,
                          scalable: false,
                          maintainAspectRatio: true)
}

func getVPAIDCreative() -> AdCreative.VPAID {
    let testURL = URL(string: "https://")!
    return AdCreative.VPAID(url: testURL,
                            adParameters: "",
                            clickthrough: testURL,
                            pixels: AdPixels(),
                            id: "")
}
