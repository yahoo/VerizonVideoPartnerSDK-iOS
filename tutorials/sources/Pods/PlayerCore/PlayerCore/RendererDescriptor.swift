//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct Descriptor: Equatable {
    public let id: String
    public let version: String
    
    public init(id: String, version: String) {
        self.id = id
        self.version = version
    }
}
