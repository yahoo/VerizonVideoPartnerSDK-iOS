//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

struct VRMProvider {
    let session: URLSession
    
    struct Response {
        let transactionId: String?
        let slot: String
        let cpm: CostPerMille?
        let items: [[Item]]
    }
    
    static func parseTransactionId(from json: JSON) -> String? {
        return json.parse("txid")
    }
    
    static func parseSlot(from json: JSON) throws -> String {
        return try json.parse("slot")
    }
    
    static func parseGroups(from json: JSON) throws -> [[JSON]] {
        return try json.parse("aeg")
    }
    
    static func parseCpm(from json: JSON) throws -> CostPerMille? {
        return json.parse("cpm")
    }
    
    static func parse(json: JSON) throws -> Response {
        return Response(
            transactionId: parseTransactionId(from: json),
            slot: try parseSlot(from: json),
            cpm: try parseCpm(from: json),
            items: try parseGroups(from: json).map { try $0.map(parseItem) })
    }
    
    static func parseItem(json: JSON) throws -> Item {
        let metaInfo = Item.MetaInfo(
            engineType: parseAdEngineType(from: json),
            ruleId: parseRuleId(from: json),
            ruleCompanyId: parseRuleCompanyId(from: json),
            vendor: try parseVendor(from: json),
            name: parseName(from: json))
        if let vast = try? parseVAST(from: json) { return .vast(vast, metaInfo) }
        if let url = try? parseURL(json: json) { return .url(url, metaInfo) }
        
        // At this point nor vast or url was detected
        enum Error: Swift.Error { case CannotExtractAdEngineFromJSON(JSON) }
        
        throw Error.CannotExtractAdEngineFromJSON(json)
    }
    
    enum Item {
        struct MetaInfo {
            let engineType: String?
            let ruleId: String?
            let ruleCompanyId: String?
            let vendor: String
            let name: String?
        }
        
        case vast(String, MetaInfo)
        case url(URL, MetaInfo)
    }
    
    static func parseURL(json: JSON) throws -> URL {
        return try VideoProvider.Parse.url(from: try json.parse("url"))
    }
    
    static func parseVAST(from json: JSON) throws -> String {
        return try json.parse("vastXml")
    }
    
    static func parseRuleCompanyId(from json: JSON) -> String? {
        return json.parse("rcid")
    }
    
    static func parseVendor(from json: JSON) throws -> String {
        return try json.parse("vendor")
    }
    
    static func parseName(from json: JSON) -> String? {
        return json.parse("name")
    }
    
    static func parseRuleId(from json: JSON) -> String? {
        return json.parse("rid")
    }
    
    static func parseAdEngineType(from json: JSON) -> String? {
        return json.parse("adEngineType")
    }
    
    func requestAds(for url: URL) -> Future<Response?> {
        let request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 2.5)
        return requestAds(with: request)
    }
    
    func requestAds(with request: URLRequest) -> Future<Response?> {
        return session.dataFuture(with: request)
            .map(Network.Parse.successResponseData)
            .map(Network.Parse.json)
            .map(Network.Parse.jsonObject)
            .map(VRMProvider.parse)
            .map { $0.value }
    }
}
