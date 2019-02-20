//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

enum VRMItem: Action {
    case start(Start)
    case model(Model)
    case timeout(Timeout)
    case other(Other)
}

extension VRMItem {
    struct Start {
        let info: VRMMetaInfo
        let url: URL
        let requestDate: Date
    }
    
    struct Model {
        let adId: String?
        let info: VRMMetaInfo
        let model: Ad.VASTModel
        let requestDate: Date
        let responseDate: Date
    }
    
    struct Timeout {
        let info: VRMMetaInfo
        let requestDate: Date
        let responseDate: Date
    }
    
    struct Other {
        let info: VRMMetaInfo
        let error: Error?
        let requestDate: Date
        let responseDate: Date
    }
}

public struct VRMMetaInfo: Hashable {
    public let engineType: String?
    public let ruleId: String?
    public let ruleCompanyId: String?
    public let vendor: String
    public let name: String?
    public let cpm: String?
    
    public init(engineType: String?,
                ruleId: String?,
                ruleCompanyId: String?,
                vendor: String,
                name: String?,
                cpm: String?) {
        self.engineType = engineType
        self.ruleId = ruleId
        self.ruleCompanyId = ruleCompanyId
        self.vendor = vendor
        self.name = name
        self.cpm = cpm
    }
}
