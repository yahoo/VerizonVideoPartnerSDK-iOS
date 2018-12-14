//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

enum Ad { }

extension Ad {
    struct Metrics {
        typealias TransactionId = String
        typealias Timeout = Int
        typealias ResponseTime = UInt
        typealias ErrorMessage = String
        typealias FiredRequests = Int
        typealias AdId = String
        
        let request: (Info, TransactionId?) -> Void
        let response:(
        Info, ResponseStatus?, ResponseTime?,
        Timeout?, FillType?, TransactionId?) -> Void
        let issue: (Info, ErrorMessage?, TransactionId?, AdId?) -> Void
        let flow: (Info, ExecutionStage, TransactionId?, AdId?) -> Void
        let vrmStart: (Info, Int) -> Void
        let vrmRequest: (FiredRequests, TransactionId?) -> Void
        let mrcAdViewGroupM: (Info, Int, Bool) -> Void
    }
}

extension Ad.Metrics {
    struct Info {
        let engineType: String?
        let ruleId: String?
        let ruleCompanyId: String?
        let vendor: String
        let name: String?
    }
    
    enum PlayType: String {
        case preroll, midroll
    }
    
    enum ResponseStatus: String {
        case yes, no, timeout
    }
    
    enum FillType: String {
        case beforeSoft = "0"
        case afterSoft = "1"
        case afterHard = "2"
    }
    
    enum ExecutionStage: String {
        case load
        case finished
        case started
        case starting
        case skipped
        case killed
        case win
        case loaded
        case Quartile1 = "q1"
        case Quartile2 = "q2"
        case Quartile3 = "q3"
    }
    enum Error: Swift.Error { case timeout, failure }
}

extension Ad.Metrics.Info {
    init(metaInfo: VRMProvider.Item.MetaInfo) {
        self.engineType = metaInfo.engineType
        self.ruleId = metaInfo.ruleId
        self.ruleCompanyId = metaInfo.ruleCompanyId
        self.vendor = metaInfo.vendor
        self.name = metaInfo.name
    }
}
