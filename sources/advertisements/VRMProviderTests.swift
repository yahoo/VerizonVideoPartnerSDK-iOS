//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Quick
import Nimble
@testable import VerizonVideoPartnerSDK

class VRMProviderTests: QuickSpec {
    override func spec() { //swiftlint:disable:this function_body_length
        describe("groups parsing") {
            let parse = VRMProvider.parseGroups
            
            let group1 = [
                ["A": "test" as Any],
                ["B": "test2" as Any]
            ]
            
            let group2 = [
                ["1": "test"],
                ["2": "test2"]
            ]
            
            context("of correct json") {
                it("should parse empty group") {
                    let result = try? parse(["aeg": []])
                    expect(result).toNot(beNil())
                    expect(result?.count) == 0
                }
                
                it("should parse empty group") {
                    let result = try? parse(["aeg": [[]]])
                    expect(result).toNot(beNil())
                    expect(result?.count) == 1
                    expect(result?.first?.count) == 0
                }
                
                it("should parse single group") {
                    let result = try? parse(["aeg": [group1]])
                    expect(result).toNot(beNil())
                    expect(result! == [group1]) == true
                }
                
                it("should parse multiple groups") {
                    let result = try? parse(["aeg": [group1, group2]])
                    expect(result).toNot(beNil())                    
                    expect(result! == [group1, group2]) == true
                }
            }
            
            context("of mised key") {
                it("should throw an error") {
                    expect { try parse(["aeg2": [[]] ]) }.to(throwError())
                }
            }
            
            context("of incorrect type") {
                it("should throw an error on plain array") {
                    expect { try parse(["aeg": group1 ]) }.to(throwError())
                }
            }
        }
        
        describe("cpm parsing") {
            it("should return nil even if value is missing") {
                expect {
                    let result = try VRMProvider.parseCpm(from: [:])
                    expect(result).to(beNil())
                    return result
                }.toNot(throwError())
            }
            
            it("should return value if it is encoded in base64") {
                expect {
                    let result = try VRMProvider.parseCpm(from: ["cpm" : "NTA="])
                    expect(result).toNot(beNil())
                    expect(result) == "50"
                    return result
                }.toNot(throwError())
            }
            
            it("should return nil if there if value is not encoded in base64") {
                expect {
                    let result = try VRMProvider.parseCpm(from: ["cpm" : "cpm"])
                    expect(result).to(beNil())
                    return result
                    }.toNot(throwError())
            }
        }
        
        describe("url parsing") {
            let parse = VRMProvider.parseURL
            let url = URL(string: "http://test.com")!
            
            context("of correct json") {
                it("should extract url") {
                    expect { try parse(["url": url.absoluteString]) } == url
                }
            }
        }
        
        describe("vast parsing") {
            let parse = VRMProvider.parseVAST
            
            it("should extract vast") {
                expect { try parse(["vastXml": "vast"]) } == "vast"
            }
        }
        
        describe("item parsing") {
            let parse = VRMProvider.parseItem
            
            it("should extract vast") {
                do {
                    if case let .vast(text, metaInfo) = try parse([
                        "vastXml": "vast",
                        "vendor" : "vendor",
                        "cpm" : "NTA="]) {
                        expect(text) == "vast"
                        expect(metaInfo.vendor) == "vendor"
                        expect(metaInfo.cpm) == "50"
                        expect(metaInfo.engineType).to(beNil())
                        expect(metaInfo.name).to(beNil())
                        expect(metaInfo.ruleCompanyId).to(beNil())
                        expect(metaInfo.ruleId).to(beNil())
                    } else {
                        fail()
                    }
                } catch { fail() }
            }
            
            it("should extract url") {
                do {
                    if case let .url(url, metaInfo) = try parse([
                        "url" : "http://test.com",
                        "vendor" : "vendor",
                        "cpm" : "NTA="]) {
                        expect(url.absoluteString) == "http://test.com"
                        expect(metaInfo.vendor) == "vendor"
                        expect(metaInfo.cpm) == "50"
                        expect(metaInfo.engineType).to(beNil())
                        expect(metaInfo.name).to(beNil())
                        expect(metaInfo.ruleCompanyId).to(beNil())
                        expect(metaInfo.ruleId).to(beNil())
                    } else {
                        fail()
                    }
                } catch { fail() }
            }
            
            it("should throw if none of filed are present") {
                expect { try parse([:]) }.to(throwError())
            }
            
            it("should should prefer vast over url") {
                let json = ["vastXml": "vast",
                            "url": "http://test.com",
                            "vendor" : "vendor"]
                do {
                    if case let .vast(text, _) = try parse(json) {
                        expect(text) == "vast"
                    } else {
                        fail()
                    }
                } catch { fail() }
            }
        }
    }
}
