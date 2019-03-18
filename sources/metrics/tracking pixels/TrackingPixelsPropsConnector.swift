//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

extension TrackingPixels {
    struct PropsConnector {
        let failoverDetector = Detectors.Failover()
        
        let reporter: Reporter
        
        init(reporter: Reporter) { self.reporter = reporter }
        
        func process(_ props: TrackingPixels.Properties) {
            func engineFlow(stage: Ad.Metrics.ExecutionStage) {
                guard let adMetricsInfo = props.metaInfo.adMetricsInfo else { return }
                reporter.adEngineFlow(videoIndex: props.session.videoIndex,
                                      info: adMetricsInfo,
                                      type: props.metaInfo.adType,
                                      stage: stage,
                                      width: props.session.playerDimensions?.width,
                                      height: props.session.playerDimensions?.height,
                                      autoplay: props.session.isAutoplayEnabled,
                                      transactionId: props.metaInfo.transactionId,
                                      adId: props.metaInfo.adVASTId,
                                      videoViewUID: props.session.playbackSessionId)
            }
            
            guard failoverDetector.process(isVRMResponseGroupsEmpty: props.session.isVRMResponseGroupsEmpty,
                                           isCurrentVRMGroupEmpty: props.session.isCurrentVRMGroupEmpty,
                                           isVRMGroupsQueueEmpty: props.session.isVRMGroupsQueueEmpty,
                                           adSessionId: props.metaInfo.adRequestId) else { return }
            engineFlow(stage: .failover)
        }
    }
}
