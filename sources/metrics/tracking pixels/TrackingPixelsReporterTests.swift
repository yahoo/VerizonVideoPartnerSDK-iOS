//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK

extension TrackingPixels.Reporter.Item: Equatable {
    public static func ==(lhs: TrackingPixels.Reporter.Item, rhs: TrackingPixels.Reporter.Item) -> Bool {
        switch (lhs, rhs) {
        case (.tracking, .tracking): return true
        case (.advertisement, .advertisement): return true
        case let (.thirdParty(lUrl), .thirdParty(rUrl)): return lUrl == rUrl
        default:
            return false
        }
    }
}

class TrackingPixelsReporterTests: XCTestCase {
    var reporter: TrackingPixels.Reporter!
    let recorder = Recorder()

    override func setUp() {
        reporter = TrackingPixels.Reporter(
            context: .init(playerID: "playerID",
                           applicationID: "applicationID",
                           buyingCompanyID: "buyingCompanyID",
                           videoObjectIDs: ["videoObjectId1"],
                           playlistID: nil,
                           playerVersion: nil,
                           playerType: "playerType",
                           sessionID: "sessionId",
                           uuid: "uuid",
                           siteSection: nil,
                           platformSupport: "platformSupport",
                           referringURL: "referringUrl",
                           vcdn: nil,
                           apid: nil,
                           mpid: nil,
                           vcid: nil,
                           spaceId: "spaceId"),
            sendMetric: recorder.hook("sendMetric")) { "cachebuster" }
        super.setUp()
    }
    
    let stubComps = URLComponents(string: "")!
    
    func testVideoDecile() {
        recorder.record {
            reporter.videoDecile(videoIndex: 0,
                                 decileNumber: 0,
                                 isAutoplay: nil,
                                 videoViewUID: "videoViewUid",
                                 timestamp: nil)
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testVideoQuartile() {
        recorder.record {
            reporter.videoQuartile(videoIndex: 0,
                                   quartile: 0,
                                   isAutoplay: nil,
                                   videoViewUID: "videoViewUid",
                                   timestamp: nil)
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testVideoPlay() {
        recorder.record {
            reporter.videoPlay(videoIndex: 0,
                               dimensions: CGSize(width: 100, height: 100),
                               isAutoplay: nil,
                               videoViewUID: "videoViewUid",
                               timestamp: nil)
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testVideoStats() {
        recorder.record {
            reporter.videoStats(numberOfVideos: 0,
                                overallPlayedTime: 0,
                                numberOfAds: 0,
                                videoIndex: 0,
                                videoViewUID: "videoViewUid")
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testVideoTime() {
        recorder.record {
            reporter.videoTime(videoIndex: 0,
                               isAutoplay: false,
                               playedTime: 0,
                               currentProgress: nil,
                               videoViewUID: "videoViewUid",
                               timestamp: nil)
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testContextStarted() {
        recorder.record {
            reporter.contextStarted(videoIndex: 0, videoViewUID: "videoViewUid")
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testImpression() {
        recorder.record {
            reporter.impression()
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testDisplays() {
        recorder.record {
            reporter.displays(size: nil,
                              videoIndex: 0,
                              videoViewUID: "videoViewUid",
                              timestamp: nil)
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testSlotOpportunity() {
        recorder.record {
            reporter.slotOpportunity(videoIndex: 0,
                                     slot: "slot",
                                     transactionId: nil,
                                     width: nil,
                                     videoViewUID: "videoViewUid",
                                     type: .preroll)
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testThreeSecPlayback() {
        recorder.record {
            reporter.threeSecPlayback(videoIndex: 0,
                                      isAutoplay: false,
                                      videoViewUID: "videoViewUid",
                                      bufferedTime: nil,
                                      averageBitrate: nil,
                                      currentTime: nil,
                                      volume: 0)
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testHeartbeat() {
        recorder.record {
            reporter.heartbeat(videoIndex: 0,
                               isAutoplay: false,
                               videoViewUID: "videoViewUid",
                               width: 0,
                               height: 0,
                               playedTime: 0,
                               bufferedTime: 0,
                               averageBitrate: nil,
                               volume: 0)
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testVideoImpression() {
        recorder.record {
            reporter.videoImpression(videoIndex: 0,
                                     isAutoplay: false,
                                     timestamp: nil,
                                     size: nil)
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testAdVideTime() {
        recorder.record {
            reporter.adViewTime(videoIndex: 0,
                                info: .init(engineType: nil,
                                            ruleId: nil,
                                            ruleCompanyId: nil,
                                            vendor: "vendor",
                                            name: nil,
                                            cpm: nil),
                                type: .preroll,
                                videoViewUID: "videoViewUid",
                                adId: nil,
                                transactionId: nil,
                                adCurrentTime: 0,
                                adDuration: 0)
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testAdEngineRequest() {
        recorder.record {
            reporter.adEngineRequest(videoIndex: 0,
                                     info: .init(engineType: nil,
                                                 ruleId: nil,
                                                 ruleCompanyId: nil,
                                                 vendor: "vendor",
                                                 name: nil,
                                                 cpm: nil),
                                     type: .preroll,
                                     transactionId: nil,
                                     videoViewUID: "videoViewUid")
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testAdEngineResponse() {
        recorder.record {
            reporter.adEngineResponse(videoIndex: 0,
                                      info: .init(engineType: nil,
                                                  ruleId: nil,
                                                  ruleCompanyId: nil,
                                                  vendor: "vendor",
                                                  name: nil,
                                                  cpm: nil),
                                      type: .preroll,
                                      responseStatus: nil,
                                      responseTime: nil,
                                      timeout: nil,
                                      fillType: nil,
                                      transactionId: nil,
                                      videoViewUID: "videoViewUid")
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testAdEngineIssue() {
        recorder.record {
            reporter.adEngineIssue(videoIndex: 0,
                                   info: .init(engineType: nil,
                                               ruleId: nil,
                                               ruleCompanyId: nil,
                                               vendor: "vendor",
                                               name: nil,
                                               cpm: nil),
                                   type: .preroll,
                                   errorMessage: nil,
                                   stage: nil,
                                   transactionId: nil,
                                   adId: nil,
                                   videoViewUID: "videoViewUid")
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testAdEngineFlow() {
        recorder.record {
            reporter.adEngineFlow(videoIndex: 0,
                                  info: .init(engineType: nil,
                                              ruleId: nil,
                                              ruleCompanyId: nil,
                                              vendor: "vendor",
                                              name: nil,
                                              cpm: nil),
                                  type: .preroll,
                                  stage: nil,
                                  width: nil,
                                  height: nil,
                                  autoplay: false,
                                  transactionId: nil,
                                  adId: nil,
                                  videoViewUID: "videoViewUid")
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testAdVrmRequest() {
        recorder.record {
            reporter.adVRMRequest(videoIndex: 0,
                                  type: .preroll,
                                  sequenceNumber: 0,
                                  transactionId: nil,
                                  videoViewUID: "videoViewUid")
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testMrcAdViewGroupM() {
        recorder.record {
            reporter.mrcAdViewGroupM(videoIndex: 0,
                                     info: .init(engineType: nil,
                                                 ruleId: nil,
                                                 ruleCompanyId: nil,
                                                 vendor: "vendor",
                                                 name: nil,
                                                 cpm: nil),
                                     type: .preroll,
                                     autoplay: false,
                                     videoViewUID: "videoViewUid")
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testAdStart() {
        recorder.record {
            reporter.adStart(info: .init(engineType: nil,
                                         ruleId: nil,
                                         ruleCompanyId: nil,
                                         vendor: "vendor",
                                         name: nil,
                                         cpm: nil),
                             videoIndex: 0,
                             videoViewUID: "videoViewUid")
        }
        
        recorder.verify {
            reporter.sendMetric(.advertisement(stubComps))
        }
    }
    
    func testAdServerRequest() {
        recorder.record {
            reporter.adServerRequest(info: .init(engineType: nil,
                                                 ruleId: nil,
                                                 ruleCompanyId: nil,
                                                 vendor: "vendor",
                                                 name: nil,
                                                 cpm: nil),
                                     videoIndex: 0,
                                     videoViewUID: "videoViewUid")
        }
        
        recorder.verify {
            reporter.sendMetric(.advertisement(stubComps))
        }
    }
    
    func testIntent() {
        recorder.record {
            reporter.intent(videoIndex: 0,
                            videoViewUID: "videoViewUid",
                            videoUrl: nil)
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testStart() {
        recorder.record {
            reporter.start(videoIndex: 0,
                           videoViewUID: "videoViewUid",
                           intentElapsedTime: nil)
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testBufferingStart() {
        recorder.record {
            reporter.bufferingStart(videoIndex: 0,
                                    videoViewUID: "videoViewUid",
                                    intentElapsedTime: nil,
                                    playedTime: 0)
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testBufferingEnd() {
        recorder.record {
            reporter.bufferingEnd(videoIndex: 0,
                                  videoViewUID: "videoViewUid",
                                  bufferingTime: 0,
                                  playedTime: 0)
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testError() {
        recorder.record {
            reporter.error(videoIndex: 0,
                           videoViewUID: "videoViewUid",
                           error: NSError(domain: "", code: 0, userInfo: nil),
                           currentVideoTime: 0)
        }
        
        recorder.verify {
            reporter.sendMetric(.tracking(stubComps))
        }
    }
    
    func testSendBeacon() {
        let testUrl1 = URL(string: "testUrl1")!
        let testUrl2 = URL(string: "testUrl2")!
        
        recorder.record {
            reporter.sendBeacon(urls: [testUrl1, testUrl2])
        }
        
        recorder.verify {
            reporter.sendMetric(.thirdParty(testUrl1))
            reporter.sendMetric(.thirdParty(testUrl2))
        }
    }
}
