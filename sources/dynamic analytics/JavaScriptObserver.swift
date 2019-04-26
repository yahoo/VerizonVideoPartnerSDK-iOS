//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import JavaScriptCore

class AnalyticsObserver {
    struct Issue {
        let type: String
        let metadata: [String : JSøN]
    }
    
    private enum State {
        class Box {
            var props: [Player.Properties] = []
            var ad: [JSøN] = []
        }
        case waiting(Box)
        
        struct Processor {
            let props: JSValue
            let ad: JSValue
        }
        case ready(Processor)
    }
    private var state = State.waiting(.init())
    
    let queue = DispatchQueue(label: "js observer")
    
    init(context: JSON,
         jsSourceUrl: URL,
         session: URLSession,
         send: @escaping (URL) -> Void,
         report: @escaping (Issue) -> Void) {
        
        func process(script: Data) {
            guard let script = String(data: script, encoding: .utf8) else {
                return report(Issue(type: "cannotDecodeDataFromScriptFile",
                                    metadata: [:]))
            }
            
            guard let jsContext = JSContext() else {
                return report(Issue(type: "cannotInstantiateNewContext",
                                    metadata: [:]))
            }
            
            jsContext.exceptionHandler = { context, error in
                report(Issue(
                    type: "jsContextException",
                    metadata: ["description" : String(describing: error) |> json]))
            }
            
            jsContext.evaluateScript(script)
            
            let sendURL: @convention(block) (String) -> Void = { url in
                URL(string: url).map(send)
            }
            
            let print: @convention(block) (JSValue) -> Void = { obj in
                Swift.print(obj)
            }
            
            let deviceValue = JSValue(newObjectIn: jsContext)!
            deviceValue.setValue(print, forProperty: "print")
            deviceValue.setValue(sendURL, forProperty: "sendURL")
            
            guard let makeProcessor =
                jsContext.globalObject.forProperty("VerizonVideoPartnerSDK_analytics") else {
                    return report(Issue(
                        type: "cannotExtractFunction",
                        metadata: ["name" : "VerizonVideoPartnerSDK_analytics" |> json]))
            }
            
            let processor = makeProcessor.call(withArguments: [context, deviceValue]) as JSValue
            
            guard !processor.isUndefined else {
                return report(Issue(type: "processorIsUndefined",
                                    metadata: [:]))
            }
            
            guard
                let propsProcessor = processor.forProperty("props"),
                !propsProcessor.isUndefined else {
                    return report(Issue(type: "propsProcessorIsEmpty", 
                                        metadata: [:]))
            }
            
            guard
                let adProcessor = processor.forProperty("ad"),
                !adProcessor.isUndefined else {
                    return report(Issue(type: "adProcessorIsEmpty",
                                        metadata: [:]))
            }
            
            guard case .waiting(let box) = state else {
                preconditionFailure("internal logic failure")
            }
            
            state = .ready(.init(
                props: propsProcessor,
                ad: adProcessor))
            
            queue.async {
                box.props.forEach(self.process)
                box.ad.forEach(self.process)
            }
        }
        
        session
            .dataFuture(with: jsSourceUrl)
            .map(Network.Parse.successResponseData)
            .onSuccess(call: process)
            .onError(call: { error in
                report(Issue(type: "networkError",
                             metadata: ["description" : String(describing: error) |> json]))
            })
    }
    
    func process(_ props: Player.Properties) {
        switch state {
        case .waiting(let box): box.props.append(props)
        case .ready(let processor):
            queue.async {
                guard let value = JSValue(object: json(for: props).jsonObject,
                                          in: processor.props.context)
                    else {
                        preconditionFailure("cannot convert json to jsvalue")
                }
                
                processor.props.call(withArguments: [value])
            }
        }
    }
    
    func process(_ metric: JSøN) {
        switch state {
        case .waiting(let box): box.ad.append(metric)
        case .ready(let processor):
            queue.async {
                processor.ad.call(withArguments: [JSValue(object: metric.object,
                                                          in: processor.ad.context)])
            }
        }
    }
}

