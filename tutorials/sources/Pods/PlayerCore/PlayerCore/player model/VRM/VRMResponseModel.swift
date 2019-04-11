//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public extension VRMCore {
    
    struct ID<ParentType>: Hashable {
        let value: UUID
        
        public init(value: UUID = UUID()) {
            self.value = value
        }
    }
    
    struct Group: Equatable {
        public typealias ID = VRMCore.ID<Group>
        
        public let id: ID
        public let items: [Item]
        
        public init(items: [Item]) {
            self.id = ID()
            self.items = items
        }
    }
    
    struct Item: Hashable {
        
        public enum Source: Hashable {
            case vast(String)
            case url(URL)
        }
        
        public struct MetaInfo: Hashable {
            public let id: ID<MetaInfo>
            public let engineType: String?
            public let ruleId: String?
            public let ruleCompanyId: String?
            public let vendor: String
            public let name: String?
            public let cpm: String?
            
            public init(id: ID<MetaInfo> = ID(),
                        engineType: String?,
                        ruleId: String?,
                        ruleCompanyId: String?,
                        vendor: String,
                        name: String?,
                        cpm: String?) {
                self.id = id
                self.engineType = engineType
                self.ruleId = ruleId
                self.ruleCompanyId = ruleCompanyId
                self.vendor = vendor
                self.name = name
                self.cpm = cpm
            }
        }
        
        public let id: ID<Item>
        public let source: Source
        public let metaInfo: MetaInfo
        
        public init(id: ID<Item> = ID<Item>(),
                    source: Source,
                    metaInfo: MetaInfo) {
            self.id = id
            self.source = source
            self.metaInfo = metaInfo
        }
    }
}
