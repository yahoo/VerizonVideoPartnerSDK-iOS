//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

enum XML {
    class Delegate: NSObject, XMLParserDelegate {
        
        var didStartElement: Action<(name: String, attributes: [String: String])>?
        var didFoundCharacters: Action<String>?
        var didFoundData: Action<Data>?
        var didEndElement: Action<String>?
        
        @objc func parser(_ parser: XMLParser,
                          didStartElement elementName: String,
                          namespaceURI: String?,
                          qualifiedName qName: String?,
                          attributes attributeDict: [String : String]) {
            self.didStartElement?((name: elementName, attributes: attributeDict))
        }
        
        @objc func parser(_ parser: XMLParser,
                          didEndElement elementName: String,
                          namespaceURI: String?,
                          qualifiedName qName: String?) {
            self.didEndElement?(elementName)
        }
        
        @objc func parser(_ parser: XMLParser, foundCharacters string: String) {
            self.didFoundCharacters?(string)
        }
        
        @objc func parser(_ parser: XMLParser, foundCDATA data: Data) {
            self.didFoundData?(data)
        }
        
        override init() { super.init() }
        
        convenience init(setup: (Delegate) -> Void) {
            self.init()
            setup(self)
        }
    }
    
    class StackDelegate: NSObject, XMLParserDelegate {
        private var stack = [] as [XMLParserDelegate]
        
        func push(_ delegate: XMLParserDelegate) {
            stack.append(delegate)
        }
        
        func pop() {
            stack.removeLast()
        }
        
        @objc func parser(_ parser: XMLParser,
                          didStartElement elementName: String,
                          namespaceURI: String?,
                          qualifiedName qName: String?,
                          attributes attributeDict: [String : String]) {
            stack.last?.parser?(parser,
                                didStartElement: elementName,
                                namespaceURI: namespaceURI,
                                qualifiedName: qName,
                                attributes: attributeDict)
        }
        
        @objc func parser(_ parser: XMLParser,
                          didEndElement elementName: String,
                          namespaceURI: String?,
                          qualifiedName qName: String?) {
            stack.last?.parser?(parser,
                                didEndElement: elementName,
                                namespaceURI: namespaceURI,
                                qualifiedName: qName)
        }
        
        @objc func parser(_ parser: XMLParser, foundCharacters string: String) {
            stack.last?.parser?(parser, foundCharacters: string)
        }
        
        @objc func parser(_ parser: XMLParser, foundCDATA data: Data) {
            stack.last?.parser?(parser, foundCDATA: data)
        }
    }
}
