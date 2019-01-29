import XCTest
@testable import VerizonVideoPartnerSDK

class AdViewTimeDetectorTests: XCTestCase {
    var sut: Detectors.AdViewTime!
    var input: Detectors.AdViewTime.Input!
    var expected = Detectors.AdViewTime.Result(duration: 15,
                                               time: 15,
                                               videoIndex: 0,
                                               vvuid: UUID().uuidString)
    
    override func setUp() {
        super.setUp()
        sut = Detectors.AdViewTime()
        input = createInput()
    }
    
    override func tearDown() {
        sut = nil
        input = nil
        super.tearDown()
    }
    
    func createInput(duration: Double? = nil,
                     currentTime: Double = 0,
                     isAdFinished: Bool = false,
                     isSessionCompleted: Bool = false,
                     videoIndex: Int = 0,
                     vvuid: String? = nil) -> Detectors.AdViewTime.Input {
        let videoViewUID = vvuid ?? expected.vvuid
        return Detectors.AdViewTime.Input(duration: duration,
                                          currentTime: currentTime,
                                          isAdFinished: isAdFinished,
                                          isSessionCompleted: isSessionCompleted,
                                          videoIndex: videoIndex,
                                          vvuid: videoViewUID)
    }
    
    func testAdFinished() {
        input = createInput()
        XCTAssertNil(sut.process(newInput: input))
        
        input = createInput(duration: 15)
        XCTAssertNil(sut.process(newInput: input))
        
        input = createInput(duration: 15,
                            currentTime: 15,
                            isAdFinished: true)
        
        if let result = sut.process(newInput: input) {
            XCTAssert(result == expected)
        } else { XCTFail("Couldn't get result") }
        
        input = createInput(duration: 15,
                            currentTime: 15,
                            isAdFinished: true)
        XCTAssertNil(sut.process(newInput: input))
    }
    
    func testForEmptyDurationWhileProcess() {
        input = createInput(duration: 15)
        XCTAssertNil(sut.process(newInput: input))
        
        input = createInput(duration: nil,
                            currentTime: 15)
        if let result = sut.process(newInput: input) {
            XCTAssert(result == expected)
        } else { XCTFail("Couldn't get result")}
    }
    
    func testVideoIndexAndVideoID() {
        input = createInput(duration: 15)
        XCTAssertNil(sut.process(newInput: input))
        
        input = createInput(duration: nil,
                            currentTime: 15,
                            videoIndex: 1,
                            vvuid: UUID().uuidString)
        
        if let result = sut.process(newInput: input) {
            XCTAssert(result == expected)
        } else { XCTFail("Couldn't get result") }
        
        input = createInput(duration: 15,
                            currentTime: 15,
                            isAdFinished: true)
        XCTAssertNil(sut.process(newInput: input))
    }
    func testSessionCompleted() {
        input = createInput(duration: 15,
                            currentTime: 15,
                            isSessionCompleted: true)
        if let result = sut.process(newInput: input) {
            XCTAssert(result == expected)
        } else { XCTFail("Couldn't get result")}
    }
    
    func testCurrentTime() {
        input = createInput(duration: 15,
                            currentTime: 15)
        _ = sut.process(newInput: input)
        input = createInput(duration: 15,
                            currentTime: 14,
                            isAdFinished: true)
        if let result = sut.process(newInput: input) {
            XCTAssert(result == expected)
        } else { XCTFail("Couldn't get result")}
    }
    
}
