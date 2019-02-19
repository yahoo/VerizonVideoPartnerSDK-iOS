//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.hts reserved.

import Foundation
import PlayerCore

extension Detectors {
    final class AdVASTProgressDetector {
        
        private var offsetProcessed = Set<Int>()
        
        func process(currentTime: Double,
                     progressPixelsArray: [PlayerCore.AdVASTProgress.Pixel]) -> [URL] {
            guard progressPixelsArray.isEmpty == false else {
                offsetProcessed = []
                return []
            }
            return progressPixelsArray
                .filter {
                    $0.offsetInSeconds == Int(currentTime.rounded()) &&
                        offsetProcessed.contains($0.offsetInSeconds) == false
                }
                .compactMap {
                    offsetProcessed.insert($0.offsetInSeconds)
                    return $0.url
            }
        }
    }
}
