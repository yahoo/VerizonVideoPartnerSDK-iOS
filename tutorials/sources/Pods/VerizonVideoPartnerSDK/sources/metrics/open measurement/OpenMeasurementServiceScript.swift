//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

extension OpenMeasurement {
    static func fetchOMServiceScript(url: URL) -> Future<Result<String>> {
        return Network.get(from: url)
    }
}
