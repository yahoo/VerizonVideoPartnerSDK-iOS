//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Quick
import Nimble
@testable import VerizonVideoPartnerSDK

class VRMRequestTests: QuickSpec {
    override func spec() { //swiftlint:disable:this function_body_length
        describe("VRM request") {
            var sut: VRMRequest<String, String>!
            let recorder = Recorder()
            let outputs = VRMRequest<String, String>.Outputs(
                requestGroups: recorder.hook("requestGroups"),
                processItem: recorder.hook("processItem"),
                stop: recorder.hook("stop"),
                retrieveResult: recorder.hook("retrieveResult"),
                failToRetrieveResult: recorder.hook("failToRetrieveResult")
            )
            
            beforeEach {
                sut = VRMRequest(unimplementedHandler: unimplemented())
                sut.outputs = outputs
            }

            afterEach {
                sut = nil
                recorder.clean()
            }

            it("starts and fires request groups") {
                recorder.record { sut.inputs.start() }
                recorder.verify { sut.outputs.requestGroups() }
            }
            
            context("started") {
                beforeEach { sut.inputs.start() }
                
                
                it("have failed to receive groups") {
                    recorder.record { sut.inputs.didFailedToReceiveGroups() }
                    recorder.verify {
                        outputs.stop()
                        outputs.failToRetrieveResult()
                    }
                }
                
                it("has cancel action") {
                    recorder.record { sut.inputs.cancel() }
                    recorder.verify {
                        outputs.stop()
                        outputs.failToRetrieveResult()
                    }
                }
                
                it("did receive empty groups") {
                    recorder.record { sut.inputs.didReceiveGroups([]) }
                    recorder.verify {
                        outputs.stop()
                        outputs.failToRetrieveResult()
                    }
                }
                
                it("should stop after hard timeout") {
                    recorder.record { sut.inputs.fireHardTimeout() }
                    recorder.verify {
                        outputs.stop()
                        outputs.failToRetrieveResult()
                    }
                }
                
                it("processes items from first group") {
                    recorder.record { sut.inputs.didReceiveGroups([["A","B"], ["C", "D"]]) }
                    
                    recorder.verify {
                        outputs.processItem("A")
                        outputs.processItem("B")
                    }
                }
                
                context("with groups") {
                    beforeEach {
                        sut.inputs.didReceiveGroups([["A","B","C"], ["1", "2", "3"]])
                    }
                    
                    context("in soft mode") {
                        it("processes first item with success result") {
                            recorder.record {
                                sut.inputs.didProcessItem(("A", "http://some_url_A"))
                            }
                            
                            recorder.verify {
                                outputs.stop()
                                outputs.retrieveResult("http://some_url_A")
                            }
                        }
                        
                        it("skips any successful items in soft mode") {
                            recorder.record {
                                sut.inputs.didProcessItem(("B", "http://some_url_B"))
                                sut.inputs.didProcessItem(("C", "http://some_url_C"))
                            }
                            
                            recorder.verify { }
                        }
                        
                        it("takes first available item from soft mode") {
                            recorder.record {
                                sut.inputs.didProcessItem(("B", "http://some_url_B"))
                                sut.inputs.didProcessItem(("C", "http://some_url_C"))
                                sut.inputs.fireSoftTimeout()
                            }
                            
                            recorder.verify {
                                outputs.stop()
                                outputs.retrieveResult("http://some_url_B")
                            }
                        }
                        
                        it("processes item with failure result") {
                            recorder.record { sut.inputs.didFailToProcessItem("A") }
                            recorder.verify {}
                        }
                        
                        it("processes second item as top priority after first one failed") {
                            recorder.record {
                                sut.inputs.didFailToProcessItem("A")
                                sut.inputs.didProcessItem(("B", "http://some_url_B"))
                            }
                            
                            recorder.verify {
                                outputs.stop()
                                outputs.retrieveResult("http://some_url_B")
                            }
                        }
                        
                        it("processes next group") {
                            recorder.record {
                                sut.inputs.didFailToProcessItem("A")
                                sut.inputs.didFailToProcessItem("B")
                                sut.inputs.didFailToProcessItem("C")
                            }
                            
                            recorder.verify {
                                outputs.processItem("1")
                                outputs.processItem("2")
                                outputs.processItem("3")
                            }
                        }
                        
                        it("processed all group -> no result found") {
                            sut.inputs.didFailToProcessItem("A")
                            sut.inputs.didFailToProcessItem("B")
                            sut.inputs.didFailToProcessItem("C")
                            
                            recorder.record {
                                sut.inputs.didFailToProcessItem("1")
                                sut.inputs.didFailToProcessItem("2")
                                sut.inputs.didFailToProcessItem("3")
                            }
                            
                            recorder.verify {
                                outputs.stop()
                                outputs.failToRetrieveResult()
                            }
                        }
                    }
                    
                    context("in hard mode") {
                        beforeEach {
                            sut.inputs.fireSoftTimeout()
                        }
                        
                        it("processes any success item") {
                            recorder.record {
                                sut.inputs.didProcessItem(("B", "http://some_url_B"))
                            }
                            
                            recorder.verify {
                                outputs.stop()
                                outputs.retrieveResult("http://some_url_B")
                            }
                        }
                    }
                }
            }
        }
    }
}
