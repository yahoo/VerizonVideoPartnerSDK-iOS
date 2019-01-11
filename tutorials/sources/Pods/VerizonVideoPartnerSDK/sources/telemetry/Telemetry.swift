//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public protocol TelemetryStationListener: class {
    func process(event: Telemetry.Event, in context: Telemetry.Context, at time: Date)
}

public enum Telemetry {
    public struct Context {
        public weak var host: AnyObject?
        public let type: String
        public let time = Date()
        
        init<T: AnyObject>(host: T) {
            self.host = host
            self.type = String(reflecting: T.self)
        }
        
        func isType<U>(type: U.Type) -> Bool {
            return self.type == String(reflecting: U.self)
        }
    }
    
    public enum Event {
        case Init, Deinit, Log(JSON)
    }
    
    public struct Listeners {
        public static let console = Console()
    }
    
    public final class Station {
        public static let shared = Station()
        private let queue = DispatchQueue(label: "com.VerizonVideoPartnerSDK.telemetry_station")
        
        private var channels: [UUID : Context] = [:]
        
        func makeChannel<T: AnyObject>(for host: T) -> Channel {
            let context = Context(host: host)
            let id = UUID()
            queue.async {
                self.publish(event: .Init, in: context)
                self.channels[id] = context
            }
            
            return Channel(
                onDeinit: { [weak self] in
                    self?.queue.async {
                        self?.channels[id] = nil
                        self?.publish(event: .Deinit, in: context)
                    }
                },
                onLog: { [weak self] json in
                    self?.queue.async {
                        self?.publish(event: .Log(json), in: context)
                    }
                }
            )
        }
        
        private var listeners: [TelemetryStationListener] = []
        
        private func publish(event: Telemetry.Event, in context: Telemetry.Context, at time: Date = Date()) {
            listeners.forEach { $0.process(event: event, in: context, at: time) }
        }
        
        public func add(listener: TelemetryStationListener) {
            guard !listeners.contains(where: { $0 === listener }) else { return }
            listeners.append(listener)
        }
        
        public func remove(listener: TelemetryStationListener) {
            guard let index = listeners.index(where: { $0 === listener }) else { return }
            listeners.remove(at: index)
        }
    }
    
    public final class Channel {
        private let onDeinit: () -> Void
        private let onLog: (JSON) -> Void
        
        init(onDeinit: @escaping () -> Void,
             onLog: @escaping (JSON) -> Void) {
            self.onDeinit = onDeinit
            self.onLog = onLog
        }
        
        public func log(json: JSON) { self.onLog(json) }
        
        deinit { onDeinit() }
    }
    
    public struct CustomTelemetrySender {
        let session: URLSession
        let url: URL
        
        func send(json: JSON) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(
                withJSONObject: json,
                options: .prettyPrinted)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            session.dataTask(with: request).resume()
        }
    }
}

extension Telemetry.Listeners {
    public final class Console: TelemetryStationListener {
        public func process(event: Telemetry.Event, in context: Telemetry.Context, at time: Date) {
            print(event, context.host ?? context.type, time)
        }
    }
}
