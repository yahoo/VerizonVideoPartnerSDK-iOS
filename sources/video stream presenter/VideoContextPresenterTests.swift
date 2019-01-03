//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK

class VideoContextPresenterTests: XCTest {
    func assert(_ pairs: [(VideoContextPresenter.Input, VideoContextPresenter.Output)]) {
        
        let presenter = VideoContextPresenter()
        for (input, output) in pairs {
            XCTAssertEqual(presenter.process(input), output)
        }
    }
    
    //swiftlint:disable function_body_length
    func testPresenter() {
        assert([
            (.notStarted, .content),
            (.notStarted, .content)])
        
        assert([
            (.notStarted, .content),
            (.adLoading, .content)])
        
        assert([
            (.notStarted, .content),
            (.ad, .ad)])
        
        assert([
            (.notStarted, .content),
            (.content, .content)])
        
        assert([
            (.adLoading, .empty),
            (.notStarted, .content)])
        
        assert([
            (.adLoading, .empty),
            (.adLoading, .empty)])
        
        assert([
            (.adLoading, .empty),
            (.ad, .ad)])
        
        assert([
            (.adLoading, .empty),
            (.content, .content)])
        
        assert([
            (.ad, .ad),
            (.notStarted, .ad)])
        
        assert([
            (.ad, .ad),
            (.adLoading, .ad)])
        
        assert([
            (.ad, .ad),
            (.ad, .ad)])
        
        assert([
            (.ad, .ad),
            (.content, .content)])
        
        assert([
            (.content, .content),
            (.notStarted, .content)])
        
        assert([
            (.content, .content),
            (.adLoading, .empty)])
        
        assert([
            (.content, .content),
            (.ad, .ad)])
        
        assert([
            (.content, .content),
            (.content, .content)])
    }
}
