//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import PlayerCore

extension Telemetry.Listeners {
    public final class AdURLProcessListener: TelemetryStationListener {
        public static let shared = AdURLProcessListener()
        
        public var session: URLSession?
        public var url: URL?
                
        public func process(event: Telemetry.Event, in context: Telemetry.Context, at time: Date) {
            guard context.isType(type: AdURLProviderProcess.self) else { return }
            guard case let Telemetry.Event.Log(json) = event else { return }
            guard let url = url, let session = session else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try! JSONSerialization.data(withJSONObject: json)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            session.dataTask(with: request).resume()
        }
    }
}

final class AdURLProviderProcess {
    var steps: [JSON] = []
    private var telemetry: Telemetry.Channel! = nil
    
    private func append(json: JSON) {
        var json = json
        json["date"] = String(describing: Date())
        steps.append(json)
    }

    private var isFired = false
    func unimplementedHandler(argumnet: Any) {
        guard !isFired else { return }
        isFired = true
        
        telemetry.log(json: ["steps": steps])
    }
    
    init(for url: URL) {
        append(json: ["url": url.absoluteString])
        telemetry = Telemetry.Station.shared.makeChannel(for: self)
    }
    
    func startRequest() {
        append(json: ["step": "start"])
    }
    
    func requestGroups() {
        append(json: ["step": "request groups"])
    }
    
    private func descriptionFor(item: VRMProvider.Item) -> JSON {
        switch item {
        case let .vast(vast, meta):
            return [
                "vast": vast,
                "meta": [
                    "engine type": meta.engineType,
                    "rule id": meta.ruleId,
                    "rule company id": meta.ruleCompanyId,
                    "venor": meta.vendor,
                    "name": meta.name
                ]
            ]
            
        case let .url(url, meta):
            return [
                "url": url.absoluteString,
                "meta": [
                    "engine type": meta.engineType,
                    "rule id": meta.ruleId,
                    "rule company id": meta.ruleCompanyId,
                    "venor": meta.vendor,
                    "name": meta.name
                ]
            ]
        }
    }
    
    private func descriptionFor(result: PlayerCore.Ad.VASTModel) -> JSON {
        return [
            "media file": result.videos.first?.url.absoluteString ?? NSNull(),
            "click": result.clickthrough?.absoluteString ?? NSNull(),
            "id": result.id ?? NSNull()
        ]
    }
    
    func didReceiveGroups(_ groups: [[VRMProvider.Item]]) {
        let groupsDescription = groups.map { group in
            group.map(descriptionFor(item:))
        }
        
        append(json: ["step": "did receive groups",
                      "groups": groupsDescription ])
    }
    
    func didFailToReceiveGroups() {
        append(json: ["step": "did fail receive groups"])
    }
    
    func processItem(_ item: VRMProvider.Item) {
        append(json: ["step": "process item",
                      "item": descriptionFor(item:item)])
    }
    
    func didProcessItem(_ item: VRMProvider.Item, to result: PlayerCore.Ad.VASTModel) {
        append(json: ["step": "process item finished",
                      "item": descriptionFor(item: item),
                      "result": descriptionFor(result: result)])
    }
    
    func didFailToProcessItem(_ item: VRMProvider.Item) {
        append(json: ["step": "process item failed",
                      "item": descriptionFor(item: item)])
    }
    
    func hitSoftTimeout() {
        append(json: ["step": "soft timeout hit"])
    }
    
    func hitHardTimeout() {
        append(json: ["step": "hard timeout hit"])
    }
    
    func didStop() {
        append(json: ["step": "stop ongoing tasks"])
    }
    
    func didRetrieveResult(_ result: PlayerCore.Ad.VASTModel) {
        append(json: ["step": "finished",
                      "result": descriptionFor(result: result)])
    }
    
    func didFailToRetrieveResult() {
        append(json: ["step": "failed"])
    }
}
