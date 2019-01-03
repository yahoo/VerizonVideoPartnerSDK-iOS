//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

enum ParsingError<T>: Error {
    case missedValue
    case incorrectType(Any)
}

func parse(any: Any?) throws -> Any {
    guard let any = any else {
        throw ParsingError<Any>.missedValue
    }
    
    return any
}

func parse(any: Any?) throws -> JSON {
    let any: Any = try any |> parse
    guard let json = any as? JSON else {
        throw ParsingError<JSON>.incorrectType(any)
    }
    
    return json
}

func parse(any: Any?) throws -> String {
    let any: Any = try any |> parse
    guard let string = any as? String else {
        throw ParsingError<String>.incorrectType(any)
    }
    
    return string
}

func parse(any: Any?) throws -> URL {
    let any: Any = try any |> parse
    guard let url = URL(string: try any |> parse) else {
        throw ParsingError<String>.incorrectType(any)
    }
    
    return url
}

func parse(any: Any?) throws -> VVPSDK.Configuration.Service {
    let any: Any = try any |> parse
    let json: JSON = try any |> parse
    
    return try VVPSDK.Configuration.Service(
        url: json["url"] |> parse,
        context: json["context"] |> parse
    )
}


func parse(any: Any?) throws -> VVPSDK.Configuration.VPAID {
    let any: Any = try any |> parse
    let json: JSON = try any |> parse
    
    return try VVPSDK.Configuration.VPAID(document: json["document"] |> parse)
}

func parse(any: Any?) throws -> VVPSDK.Configuration.OpenMeasurement {
    let any: Any = try any |> parse
    let json: JSON = try any |> parse
    
    return try VVPSDK.Configuration.OpenMeasurement(script: json["script"] |> parse)
}

func parse(any: Any?) throws -> VVPSDK.Configuration.Tracking {
    let any: Any = try any |> parse
    let json: JSON = try any |> parse
    
    if json["native"] != nil {
        return .native
    } else if let javascript = json["javascript"] {
        return .javascript(try javascript |> parse)
    } else {
        struct NoSupportedTrackingSystemsPresented: Swift.Error { }
        throw NoSupportedTrackingSystemsPresented()
    }
}

func parse(any: Any?) throws -> VVPSDK.Configuration.Tracking.Javascript {
    let any: Any = try any |> parse
    let json: JSON = try any |> parse
    
    return try VVPSDK.Configuration.Tracking.Javascript(
        source: json["source"] |> parse,
        telemetry: json["telemetry"] |> parse
    )
}

func parse(any: Any?) throws -> VVPSDK.Configuration {
    let any: Any = try any |> parse
    let json: JSON = try any |> parse
    let config: JSON = try json["config"] |> parse
    
    return try VVPSDK.Configuration(
        userAgent: config["userAgent"] |> parse,
        video: config["video"] |> parse,
        vpaid: config["vpaid"] |> parse,
        openMeasurement: config["openMeasurement"] |> parse,
        tracking: config["tracking"] |> parse,
        telemetry: try? config["telemetry"] |> parse
    )
}
