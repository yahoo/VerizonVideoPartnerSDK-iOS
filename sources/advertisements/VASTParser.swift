//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

enum VASTParser {
    static func parseString(to setter: @escaping (String) -> Void) -> XMLParserDelegate {
        let delegate = XML.Delegate()
        delegate.didStartElement = { _ in fatalError("Nested elements are not expected") }
        
        var content = ""
        delegate.didFoundCharacters = {
            content += $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        delegate.didFoundData = {
            content += String(data: $0, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
        
        delegate.didEndElement = { _ in
            let replaced = content
                .replacingOccurrences(of:"\n", with: "")
                .replacingOccurrences(of: " ", with: "")
            setter(replaced)
        }
        
        return delegate
    }
    
    static func parseURL(to setter: @escaping Action<URL?>) -> XMLParserDelegate {
        return parseString {
            func createURL(_ string: String) -> URL? {
                guard let url = URL(string: string) else {
                    let encoded = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    return encoded.flatMap(URL.init(string:))
                }
                return url
            }
            setter(createURL($0))
        }
    }
    
    struct InlineContext {
        var adVerifications = [AdVerification]()
        var clickthroughURL: URL?
        var pixels = PlayerCore.AdPixels()
        var adParameters: String?
        var mp4MediaFiles: [PlayerCore.Ad.VASTModel.MP4MediaFile] = []
        var vpaidMediaFiles: [PlayerCore.Ad.VASTModel.VPAIDMediaFile] = []
        var skipOffset: PlayerCore.Ad.VASTModel.SkipOffset = .none
    }
    
    struct AdVerification {
        var vendorKey: String?
        var javaScriptResource: URL?
        var verificationParameters: URL?
        var verificationNotExecuted: URL?
    }
    
    static func parseAdVerification(to setter: @escaping Action<[AdVerification]>) -> XMLParserDelegate {
        var adVerifications = [AdVerification]()
        let delegateStack = XML.StackDelegate()
        
        delegateStack.push(XML.Delegate(setup: { delegate in
            delegate.didEndElement = { name in
                guard name == "AdVerifications" else { return }
                setter(adVerifications)
                delegateStack.pop()
            }
            delegate.didStartElement = .some { name, attr in
                guard name == "Verification" else { return }
                var adVerification = AdVerification()
                adVerification.vendorKey = attr["vendor"]
                
                delegateStack.push(XML.Delegate(setup: { delegate in
                    delegate.didEndElement = { name in
                        guard name == "Verification" else { return }
                        adVerifications.append(adVerification)
                        delegateStack.pop()
                    }
                    delegate.didStartElement = .some { name, attr in
                        switch name {
                        case "VerificationParameters":
                            delegateStack.push(parseURL(to: { url in
                                if let url = url { adVerification.verificationParameters = url }
                                delegateStack.pop()
                            }))
                        case "JavaScriptResource":
                            delegateStack.push(parseURL(to: { url in
                                if let url = url { adVerification.javaScriptResource = url }
                                delegateStack.pop()
                            }))
                        case "TrackingEvents":
                            delegateStack.push(XML.Delegate(setup: { delegate in
                                delegate.didEndElement = { name in
                                    guard name == "TrackingEvents" else { return }
                                    delegateStack.pop()
                                }
                                delegate.didStartElement = .some { name, attr in
                                    guard name == "Tracking" else { return }
                                    guard attr["event"] == "verificationNotExecuted" else { return }
                                    delegateStack.push(parseURL(to: { url in
                                        if let url = url { adVerification.verificationNotExecuted = url }
                                        delegateStack.pop()
                                    }))
                                }
                            }))
                        default: break
                        }
                    }
                }))
            }
        }))
        return delegateStack
    }
    
    //swiftlint:disable function_body_length
    //swiftlint:disable cyclomatic_complexity
    //swiftlint:disable line_length
    static func parseInline(
        with id: String?,
        to setter: @escaping Action<(InlineContext)>) -> XMLParserDelegate {
        let delegateStack = XML.StackDelegate()
        var inlineContext = InlineContext()
        
        delegateStack.push(XML.Delegate(setup: { delegate in
            
            delegate.didEndElement = { endName in
                guard endName == "InLine" else { return }
                
                setter(inlineContext)
                
                delegateStack.pop()
            }
            
            delegate.didStartElement = .some { (name, attr) -> Void in
                if let skipOffset = attr["skipoffset"] {
                    if skipOffset.contains("%") {
                        if let value = Int(skipOffset.replacingOccurrences(of: "%", with: "")) {
                            inlineContext.skipOffset = .percentage(value)
                        }
                    } else if skipOffset.contains(":") {
                        if let value = VASTTime(with: skipOffset)?.seconds {
                            inlineContext.skipOffset = .time(value)
                        }
                    }
                }
                
                switch name {
                case "Extensions":
                    delegateStack.push(XML.Delegate(setup: { delegate in
                        delegate.didEndElement = { name in
                            guard name == "Extensions" else { return }
                            delegateStack.pop()
                        }
                        
                        delegate.didStartElement = .some { name, attr in
                            guard attr["type"] == "AdVerifications" else { return }
                            delegateStack.push(parseAdVerification(to: { adVerifications in
                                delegateStack.pop()
                                
                                guard adVerifications.isEmpty == false else { return }
                                
                                inlineContext.adVerifications = adVerifications
                            }))
                        }
                    }))
                case "AdVerifications":
                    delegateStack.push(parseAdVerification(to: { adVerifications in
                        delegateStack.pop()
                        
                        guard adVerifications.isEmpty == false else { return }
                        
                        inlineContext.adVerifications = adVerifications
                    }))
                case "Error":
                    delegateStack.push(parseURL(to: { url in
                        if let url = url { inlineContext.pixels.error.append(url) }
                        delegateStack.pop()
                    }))
                    
                case "Impression":
                    delegateStack.push(parseURL(to: { url in
                        if let url = url { inlineContext.pixels.impression.append(url) }
                        delegateStack.pop()
                    }))
                    
                case "Linear":
                    delegateStack.push(XML.Delegate(setup: { delegate in
                        delegate.didEndElement = { name in
                            guard name == "Linear" else { return }
                            delegateStack.pop()
                        }
                        
                        delegate.didStartElement = .some { name, attr in
                            switch name {
                                
                            case "Tracking":
                                guard let event = attr["event"] else { break }
                                
                                delegateStack.push(parseURL(to: { url in
                                    if let url = url {
                                        switch event {
                                        case "creativeView": inlineContext.pixels.creativeView.append(url)
                                        case "start": inlineContext.pixels.start.append(url)
                                        case "firstQuartile": inlineContext.pixels.firstQuartile.append(url)
                                        case "midpoint": inlineContext.pixels.midpoint.append(url)
                                        case "thirdQuartile": inlineContext.pixels.thirdQuartile.append(url)
                                        case "complete": inlineContext.pixels.complete.append(url)
                                        case "pause": inlineContext.pixels.pause.append(url)
                                        case "resume": inlineContext.pixels.resume.append(url)
                                        case "skip": inlineContext.pixels.skip.append(url)
                                        case "mute": inlineContext.pixels.mute.append(url)
                                        case "unmute": inlineContext.pixels.unmute.append(url)
                                        case "acceptInvitation": inlineContext.pixels.acceptInvitation.append(url)
                                        case "acceptInvitationLinear": inlineContext.pixels.acceptInvitationLinear.append(url)
                                        case "close": inlineContext.pixels.close.append(url)
                                        case "closeLinear": inlineContext.pixels.closeLinear.append(url)
                                        case "collapse": inlineContext.pixels.collapse.append(url)
                                        default: break }
                                    }
                                    
                                    delegateStack.pop()
                                }))
                                
                            case "ClickThrough":
                                delegateStack.push(parseURL(to: { url in
                                    inlineContext.clickthroughURL = url
                                    delegateStack.pop()
                                }))
                                
                            case "ClickTracking":
                                delegateStack.push(parseURL(to: { url in
                                    if let url = url { inlineContext.pixels.clickTracking.append(url) }
                                    delegateStack.pop()
                                }))
                                
                            case "AdParameters":
                                delegateStack.push(parseString(to: { (parameter) in
                                    inlineContext.adParameters = parameter
                                    delegateStack.pop()
                                }))
                                
                            case "MediaFile":
                                guard let typeAttr = attr["type"] else { break }
                                guard
                                    let delivery = attr["delivery"],
                                    delivery == "progressive" else { break }
                                delegateStack.push(parseURL(to: { url in
                                    var scalable: Bool?
                                    if let scalableAttr = attr["scalable"] {
                                        scalable = scalableAttr == "true"
                                    }
                                    var maintainAspectRatio: Bool?
                                    if let maintainAspectRatioAttr = attr["maintainAspectRatio"] {
                                        maintainAspectRatio = maintainAspectRatioAttr == "true"
                                    }
                                    guard let widthAttr = attr["width"], let width = Int(widthAttr) else { return }
                                    guard let heightAttr = attr["height"], let height = Int(heightAttr) else { return }
                                    guard let url = url else { return }
                                    switch typeAttr {
                                    case "video/mp4":
                                        let mediaFile = PlayerCore.Ad.VASTModel.MP4MediaFile(
                                            url: url,
                                            width: width,
                                            height: height,
                                            scalable: scalable ?? false,
                                            maintainAspectRatio: maintainAspectRatio ?? true)
                                        inlineContext.mp4MediaFiles.append(mediaFile)
                                    case "application/javascript":
                                        guard
                                            let apiFramework = attr["apiFramework"],
                                            apiFramework == "VPAID" else { break }
                                        let mediaFile = PlayerCore.Ad.VASTModel.VPAIDMediaFile(
                                            url: url,
                                            scalable: scalable ?? false,
                                            maintainAspectRatio: maintainAspectRatio ?? true)
                                        inlineContext.vpaidMediaFiles.append(mediaFile)
                                    default: break
                                    }
                                    delegateStack.pop()
                                }))
                                
                            default: break }
                        }
                    }))
                    
                default: break }
            }
        }))
        
        return delegateStack
    }
    
    //swiftlint:disable line_length
    //swiftlint:enable function_body_length
    //swiftlint:enable cyclomatic_complexity
    
    //swiftlint:disable function_body_length
    //swiftlint:disable cyclomatic_complexity
    //swiftlint:disable line_length
    static func parseWrapper(to setter: @escaping Action<VASTModel.WrapperModel?>) -> XMLParserDelegate {
        var pixels = PlayerCore.AdPixels()
        var vastTag = nil as URL?
        var adVerificationsResult = [AdVerification]()
        
        let delegateStack = XML.StackDelegate()
        delegateStack.push(XML.Delegate(setup: { delegate in
            delegate.didEndElement = { name in
                guard name == "Wrapper" else { return }
                guard let vastTag = vastTag else { return }
                setter(VASTModel.WrapperModel(
                    tagURL: vastTag,
                    adVerifications: adVerificationsResult.compactMap {
                        guard let javascriptResource = $0.javaScriptResource else { return nil }
                        return PlayerCore.Ad.VASTModel.AdVerification(vendorKey: $0.vendorKey,
                                                                      javaScriptResource: javascriptResource,
                                                                      verificationParameters: $0.verificationParameters,
                                                                      verificationNotExecuted: $0.verificationNotExecuted)
                    },
                    pixels: pixels))
                
                delegateStack.pop()
            }
            
            delegate.didStartElement = .some { name, attr in
                switch name {
                case "Extensions":
                    delegateStack.push(XML.Delegate(setup: { delegate in
                        delegate.didEndElement = { name in
                            guard name == "Extensions" else { return }
                            delegateStack.pop()
                        }
                        
                        delegate.didStartElement = .some { name, attr in
                            guard attr["type"] == "AdVerifications" else { return }
                            delegateStack.push(parseAdVerification(to: { adVerifications in
                                delegateStack.pop()
                                
                                guard adVerifications.isEmpty == false else { return }
                                
                                adVerificationsResult = adVerifications
                            }))
                        }
                    }))
                case "AdVerifications":
                    delegateStack.push(parseAdVerification(to: { adVerifications in
                        delegateStack.pop()
                        
                        guard adVerifications.isEmpty == false else { return }
                        
                        adVerificationsResult = adVerifications
                    }))
                    
                case "VASTAdTagURI":
                    delegateStack.push(parseURL(to: { url in
                        vastTag = url
                        delegateStack.pop()
                    }))
                    
                case "Error":
                    delegateStack.push(parseURL(to: { url in
                        if let url = url { pixels.error.append(url) }
                        delegateStack.pop()
                    }))
                    
                case "Impression":
                    delegateStack.push(parseURL(to: { url in
                        if let url = url { pixels.impression.append(url) }
                        delegateStack.pop()
                    }))
                    
                case "Linear":
                    delegateStack.push(XML.Delegate(setup: { delegate in
                        delegate.didEndElement = { name in
                            guard name == "Linear" else { return }
                            delegateStack.pop()
                        }
                        
                        delegate.didStartElement = .some { name, attr in
                            switch name {
                                
                            case "Tracking":
                                guard let event = attr["event"] else { break }
                                
                                delegateStack.push(parseURL(to: { url in
                                    if let url = url {
                                        switch event {
                                        case "creativeView": pixels.creativeView.append(url)
                                        case "start": pixels.start.append(url)
                                        case "firstQuartile": pixels.firstQuartile.append(url)
                                        case "midpoint": pixels.midpoint.append(url)
                                        case "thirdQuartile": pixels.thirdQuartile.append(url)
                                        case "complete": pixels.complete.append(url)
                                        case "pause": pixels.pause.append(url)
                                        case "resume": pixels.resume.append(url)
                                        case "skip": pixels.skip.append(url)
                                        case "mute": pixels.mute.append(url)
                                        case "unmute": pixels.unmute.append(url)
                                        case "acceptInvitation": pixels.acceptInvitation.append(url)
                                        case "acceptInvitationLinear": pixels.acceptInvitationLinear.append(url)
                                        case "close": pixels.close.append(url)
                                        case "closeLinear": pixels.closeLinear.append(url)
                                        case "collapse": pixels.collapse.append(url)
                                        default: break }
                                    }
                                    
                                    delegateStack.pop()
                                }))
                                
                            case "ClickTracking":
                                delegateStack.push(parseURL(to: { url in
                                    if let url = url { pixels.clickTracking.append(url) }
                                    delegateStack.pop()
                                }))
                                
                            default: break }
                        }
                    }))
                    
                default: break }
            }
        }))
        return delegateStack
    }
    //swiftlint:disable line_length
    //swiftlint:enable function_body_length
    //swiftlint:enable cyclomatic_complexity
    
    
    
    //swiftlint:disable function_body_length
    //swiftlint:disable cyclomatic_complexity
    //swiftlint:disable line_length
    static func parse(to setter: @escaping Action<VASTModel?>) -> XMLParserDelegate {
        var result = nil as VASTModel?
        
        let delegateStack = XML.StackDelegate()
        delegateStack.push(XML.Delegate(setup: { delegate in
            delegate.didStartElement = .some { name, attr in
                guard name == "Ad" else { return }
                guard attr["sequence"] == nil else { return }
                guard result == nil else { return }
                
                let adId = attr["id"]
                
                delegateStack.push(XML.Delegate(setup: { delegate in
                    
                    delegate.didEndElement = { endName in
                        guard name == endName else { return }
                        delegateStack.pop()
                        delegateStack.pop() // HACK: Drop delegate from outer level. Not an error.
                        setter(result)
                    }
                    
                    delegate.didStartElement = .some { name, attr in
                        switch name {
                            
                        case "InLine":
                            delegateStack.push(parseInline(
                                with: adId,
                                to: { context in
                                    delegateStack.pop()
                                    
                                    guard result == nil else { fatalError("Result overwrite detected") }
                                    guard !context.vpaidMediaFiles.isEmpty || !context.mp4MediaFiles.isEmpty else { return }
                                    
                                    let adVerifications: [PlayerCore.Ad.VASTModel.AdVerification] = {
                                        guard context.adVerifications.isEmpty == false else { return [] }
                                        return context.adVerifications.compactMap {
                                            guard let javaScriptResource = $0.javaScriptResource else { return nil }
                                            return PlayerCore.Ad.VASTModel.AdVerification(
                                                vendorKey: $0.vendorKey,
                                                javaScriptResource: javaScriptResource,
                                                verificationParameters: $0.verificationParameters,
                                                verificationNotExecuted: $0.verificationNotExecuted)
                                        }
                                    }()
                                    let model = PlayerCore.Ad.VASTModel(adVerifications: adVerifications,
                                                                        mp4MediaFiles: context.mp4MediaFiles,
                                                                        vpaidMediaFiles: context.vpaidMediaFiles,
                                                                        skipOffset: context.skipOffset,
                                                                        clickthrough: context.clickthroughURL,
                                                                        adParameters: context.adParameters,
                                                                        pixels: context.pixels,
                                                                        id: adId)
                                    result = VASTModel.inline(model)
                            }))
                            
                        case "Wrapper":
                            delegateStack.push(parseWrapper(to: { model in
                                delegateStack.pop()
                                
                                guard let model = model else { return }
                                guard result == nil else { fatalError("Result overwrite detected") }
                                
                                result = VASTModel.wrapper(model)
                            }))
                            
                        default: fatalError("Unexpected element: \(name)") }
                    }
                }))
            }
        }))
        
        return delegateStack
    }
    
    struct VASTTime {
        enum Time {
            case hours([String])
            case minutes([String])
            case seconds([String])
            
            private var maxValue: Int {
                switch self {
                case .hours: return 99
                case .minutes, .seconds: return 59
                }
            }
            private var multiplier: Int {
                switch self {
                case .hours: return 3600
                case .minutes: return 60
                case .seconds: return 1
                }
            }
            private var index: Int {
                switch self {
                case .hours: return 0
                case .minutes: return 1
                case .seconds: return 2
                }
            }
            private var stringTime: String {
                switch self {
                case .hours(let value): return value[self.index]
                case .minutes(let value): return value[self.index]
                case .seconds(let value): return value[self.index]
                }
            }
            
            var resultInSeconds: Int? {
                guard let roundedSeconds = Double(self.stringTime)?.rounded() else { return nil }
                let result = Int(roundedSeconds)
                guard result <= maxValue else { return nil }
                return result * multiplier
            }
            
        }
        
        let seconds: Int
        
        init?(with time: String) {
            let components = time.components(separatedBy: ":")
            guard components.count == 3,
                let hours = Time.hours(components).resultInSeconds,
                let minutes = Time.minutes(components).resultInSeconds,
                let seconds = Time.seconds(components).resultInSeconds else { return nil }
            self.seconds = hours + minutes + seconds
        }
    }
    
    //swiftlint:disable line_length
    //swiftlint:enable function_body_length
    //swiftlint:enable cyclomatic_complexity
    
    static func parseFrom(string: String) -> VASTModel? {
        guard let data = string.data(using: .utf8) else {
            fatalError("String is not properly encoded")
        }
        
        return parseFrom(data: data)
    }
    
    static func parseFrom(data: Data) -> VASTModel? {
        var result = nil as VASTModel?

        let parser = XMLParser(data: data)
        let delegate = parse { result = $0 }
        parser.delegate = delegate
        parser.parse()
        
        return result
    }
}
