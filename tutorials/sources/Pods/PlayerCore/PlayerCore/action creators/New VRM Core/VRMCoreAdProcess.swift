//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public extension VRMCore {
    public static func adRequest(url: URL, id: UUID, type: AdType) -> Action {
        return AdRequest(url: url, id: id, type: type)
    }
}
