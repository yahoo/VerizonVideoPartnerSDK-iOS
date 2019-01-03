//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Quick
import Nimble

@testable import enum VerizonVideoPartnerSDK.Network

class NetworkTests: QuickSpec {
    //swiftlint:disable force_cast
    //swiftlint:disable function_body_length
    override func spec() {
        
        describe("single object JSON") {
            let response = Network.Parse.jsonSingleObject
            
            it("should throw an error when several jsons") {
                expect { try response([["example": "test"], ["example": "test"]]) }
                    .to(throwError())
            }
            
            it("should return correct json") {
                let json = ["expect": "test"]
                expect(try? response([json]) as! [String: String]) == json
            }
        }
        
        describe("request generation") {
            let url = URL(string: "http://test.com")!
            let request = Network.Request.from(info: .init(url: url, userAgent: nil))
            
            it("should set correct url") {
                expect(request.url) == url
            }
            
            it("should have json content-type") {
                let contentType = request.allHTTPHeaderFields?["Content-Type"]
                expect(contentType) == "application/json"
            }
        }
        
        describe("response") {
            let response = Network.Parse.successResponseData
            
            context("with network error") {
                let error = NSError(domain: "test", code: 0, userInfo: nil)
                
                it("should retrhow error") {
                    expect { try response(nil, nil, error) }
                        .to(throwError(Network.Error.connection(networkError: error)))
                }
            }
            
            context("with incorrect response code") {
                let urlResponse = HTTPURLResponse(
                    url: URL(string: "http://test.com")!,
                    statusCode: 404, httpVersion: nil, headerFields: nil)!
                let data = "".data(using: String.Encoding.utf8)
                
                it("should throw error") {
                    expect { try response(data, urlResponse, nil) }
                        .to(throwError(Network.Error.serverResponse(
                            httpResponse: urlResponse, content: "")))
                }
            }
            
            context("with correct response") {
                let urlResponse = HTTPURLResponse(
                    url: URL(string: "http://test.com")!,
                    statusCode: 200, httpVersion: nil, headerFields: nil)
                
                let data = NSData()
                
                it("should return data") {
                    expect { try response(data as Data, urlResponse, nil) }
                        .to(equal(data as Data))
                }
            }
        }
        
        describe("json parsing") {
            describe("jsonArray") {
                let jsonArray = Network.Parse.jsonArray
                
                it("should throw an error when not a [JSON] provided") {
                    expect { try jsonArray(["example": "test"]) } .to(throwError())
                }
                
                it("should throw an error when empty [] provided") {
                    expect { try jsonArray([]) } .to(throwError())
                }
                
                it("should return correct json") {
                    let jsons = [["expect": "test" as Any], ["expect": "test" as Any]]
                    let result = try? jsonArray(jsons)
                    expect(result).toNot(beNil())
                    expect(result! == jsons) == true
                }
            }
        }
    }
}
