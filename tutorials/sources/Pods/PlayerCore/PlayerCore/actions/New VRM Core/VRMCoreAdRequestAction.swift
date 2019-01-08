//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension VRMCore {
    struct AdRequest: Action {
        let url: URL
        let id: UUID
        let type: AdType
    }
}
