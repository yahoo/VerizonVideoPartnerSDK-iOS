//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Player {
    public final class Tracer {
        private(set) var actions = [JSøN]()
        private(set) var props = [JSøN]()
        private(set) var metrics = [JSøN]()
        private(set) var context: JSøN?
        
        func record(props: JSøN) {
            self.props.append(props)
        }
        
        func record(metric: JSøN) {
            metrics.append([
                "metric": metric,
                "propsCount": props.count |> json] |> json)
        }
        
        func record(context: JSøN) {
            self.context = context
        }
        
        func save(to directory: URL) throws {
            func save(json: JSøN, to file: String) throws {
                let data = try JSONSerialization.data(withJSONObject: json.object,
                                                      options: .prettyPrinted)
                try data.write(to: directory.appendingPathComponent(file))
            }
            
            try save(json: actions |> json, to: "actions.json")
            try save(json: props |> json , to: "props.json")
            try save(json: ["context": context ?? .null,
                            "metrics": metrics |> json] |> json, to: "metrics.json")
        }
    }
}
