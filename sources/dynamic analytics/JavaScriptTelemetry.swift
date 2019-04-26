//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

struct JavaScriptTelemetry {
    let session: URLSession
    let url: URL
    let context: JSON
    
    func send(issue: AnalyticsObserver.Issue) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(
            withJSONObject:["context" : context,
                            "issue" : json(for: issue).jsonObject],
            options: .prettyPrinted)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        session.dataTask(with: request).resume()
    }
}

func json(for issue: AnalyticsObserver.Issue) -> JSøN {
    var result = ["type" : issue.type |> json]
    if issue.metadata.count > 0 {
        result["metadata"] = issue.metadata |> json
    }
    return result |> json
}
