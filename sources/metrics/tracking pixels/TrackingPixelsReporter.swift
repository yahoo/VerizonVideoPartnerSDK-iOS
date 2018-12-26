//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

enum TrackingPixels {}

extension TrackingPixels {
    final class Reporter {
        enum Item {
            case tracking(URLComponents)
            case advertisement(URLComponents)
            case thirdParty(URL)
        }
        
        struct Context {
            let playerID: String
            let applicationID: String
            let buyingCompanyID: String
            let videoObjectIDs: [String]
            let playlistID: String?
            let playerVersion: String?
            let playerType: String
            let sessionID: String
            let uuid: String
            let siteSection: String?
            let platformSupport: String
            let referringURL: String
            let vcdn: [String]?
            let apid: String?
            let mpid: [String?]?
            let vcid: [String?]?
        }
        
        let context: Context
        
        // Side effects
        let sendMetric: MetricsSender.T
        let cachebuster: () -> String
        
        init(context: Context,
             sendMetric: @escaping MetricsSender.T,
             cachebuster: @escaping () -> String) {
            self.context = context
            self.sendMetric = sendMetric
            self.cachebuster = cachebuster
        }
    }
}

extension TrackingPixels.Reporter {
    func videoDecile(videoIndex: Int,
                     decileNumber: Int,
                     isAutoplay: Bool?,
                     videoViewUID: String,
                     timestamp: String?) {
        sendMetric(.tracking(
            TrackingPixels.Generator.videoDeciles(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                vid: context.videoObjectIDs[videoIndex],
                d:decilePresentation(decileNumber),
                bid: context.playlistID,
                pt: context.playerType,
                pv: context.playerVersion,
                sid: context.sessionID,
                vpt: videoPlayType(for: isAutoplay),
                ts: timestamp,
                r: context.referringURL,
                seq: String(videoIndex),
                vvuid: videoViewUID,
                vcid: context.vcid?[videoIndex],
                mpid: context.mpid?[videoIndex],
                cb: cachebuster(),
                m_fwsitesection: context.siteSection)))
    }
    
    func videoQuartile(videoIndex: Int,
                       quartile: Int,
                       isAutoplay: Bool?,
                       videoViewUID: String,
                       timestamp: String?) {
        sendMetric(.tracking(
            TrackingPixels.Generator.videoQuartiles(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                vid: context.videoObjectIDs[videoIndex],
                q: quartilePresentation(quartile),
                bid: context.playlistID,
                pt: context.playerType,
                pv: context.playerVersion,
                sid: context.sessionID,
                vpt: videoPlayType(for: isAutoplay),
                ts: timestamp,
                r: context.referringURL,
                seq: String(videoIndex),
                vvuid: videoViewUID,
                vcid: context.vcid?[videoIndex],
                mpid: context.mpid?[videoIndex],
                cb: cachebuster(),
                m_fwsitesection: context.siteSection)))
    }
    
    func videoPlay(videoIndex: Int,
                   dimensions: CGSize,
                   isAutoplay: Bool?,
                   videoViewUID: String,
                   timestamp: String?) {
        sendMetric(.tracking(
            TrackingPixels.Generator.videoPlay(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                vid: context.videoObjectIDs[videoIndex],
                bid: context.playlistID,
                vpt: videoPlayType(for: isAutoplay),
                w: String(Int(dimensions.width)),
                h: String(Int(dimensions.height)),
                pt: context.playerType,
                pv: context.playerVersion,
                sid: context.sessionID,
                ts: timestamp,
                r: context.referringURL,
                seq: String(videoIndex),
                vvuid: videoViewUID,
                vcid: context.vcid?[videoIndex],
                mpid: context.mpid?[videoIndex],
                cb: cachebuster(),
                m_fwsitesection: context.siteSection)))
    }
    
    func videoStats(
        numberOfVideos: Int,
        overallPlayedTime: TimeInterval,
        numberOfAds: Int,
        videoIndex: Int,
        videoViewUID: String)
    {
        sendMetric(.tracking(
            TrackingPixels.Generator.videoStats(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                bid: context.playlistID,
                nv: String(numberOfVideos),
                t: formatter.string(from: overallPlayedTime as NSNumber),
                ac: String(numberOfAds),
                pt: context.playerType,
                pv: context.playerVersion,
                sid: context.sessionID,
                r: context.referringURL,
                vvuid: videoViewUID,
                cb: cachebuster(),
                m_fwsitesection: context.siteSection)))
    }
    
    func videoTime(
        videoIndex: Int,
        isAutoplay: Bool,
        playedTime: TimeInterval,
        currentProgress: Progress?,
        videoViewUID: String,
        timestamp: String?)
    {
        sendMetric(.tracking(
            TrackingPixels.Generator.videoTime(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                vid: context.videoObjectIDs[videoIndex],
                bid: context.playlistID,
                vpt: videoPlayType(for: isAutoplay),
                t: formatter.string(from: playedTime as NSNumber),
                pct: currentProgress.flatMap { formatter.string(from: $0.value as NSNumber) },
                pt: context.playerType,
                pv: context.playerVersion,
                sid: context.sessionID,
                ts: timestamp,
                r: context.referringURL,
                seq: String(videoIndex),
                vvuid: videoViewUID,
                vcid: context.vcid?[videoIndex],
                mpid: context.mpid?[videoIndex],
                cb: cachebuster(),
                m_fwsitesection: context.siteSection)))
    }
    
    func contextStarted(videoIndex: Int, videoViewUID: String) {
        sendMetric(.tracking(
            TrackingPixels.Generator.contextStarted(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                bid: context.playlistID,
                vid: context.videoObjectIDs[videoIndex],
                pt: context.playerType,
                pv: context.playerVersion,
                sid: context.sessionID,
                r: context.referringURL,
                seq: String(videoIndex),
                vvuid: videoViewUID,
                vcid: context.vcid?[videoIndex],
                mpid: context.mpid?[videoIndex],
                cb: cachebuster(),
                m_fwsitesection: context.siteSection)))
    }
    
    func impression() {
        sendMetric(.tracking(
            TrackingPixels.Generator.impressions(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                bid: context.playlistID,
                pt: context.playerType,
                sid:  context.sessionID,
                r: context.referringURL,
                cb: cachebuster(),
                m_fwsitesection: context.siteSection)))
    }
    
    func displays(size: CGSize?, videoIndex: Int, videoViewUID: String, timestamp: String?) {
        sendMetric(.tracking(
            TrackingPixels.Generator.displays(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                bid: context.playlistID,
                sid: context.sessionID,
                dt: timestamp,
                w: size.map { String(Int($0.width)) },
                h: size.map { String(Int($0.height)) },
                pt: context.playerType,
                pv: context.playerVersion,
                r: context.referringURL,
                vvuid: videoViewUID,
                cb: cachebuster(),
                m_fwsitesection: context.siteSection)))
    }
    
    func slotOpportunity(videoIndex: Int,
                         slot: String,
                         transactionId: String?,
                         width: CGFloat?,
                         videoViewUID: String,
                         type: Ad.Metrics.PlayType) {
        sendMetric(.tracking(
            TrackingPixels.Generator.slotOpp(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                at: type.rawValue,
                bid: context.playlistID,
                vid: context.videoObjectIDs[videoIndex],
                slot: slot,
                pt: context.playerType,
                pv: context.playerVersion,
                ps: context.platformSupport,
                sid: context.sessionID,
                txid: transactionId,
                r: context.referringURL,
                vvuid: videoViewUID,
                cb: cachebuster(),
                s: "true",
                w: width.map { String(describing: $0) },
                m_fwsitesection: context.siteSection)))
    }
    
    func threeSecPlayback(videoIndex: Int,
                          isAutoplay: Bool,
                          videoViewUID: String,
                          bufferedTime: Int?,
                          averageBitrate: Double?,
                          currentTime: Int?,
                          volume: Int) {
        sendMetric(.tracking(
            TrackingPixels.Generator.video3Sec(
                bid: context.playlistID,
                pid: context.playerID,
                bcid: context.buyingCompanyID,
                vid: context.videoObjectIDs[videoIndex],
                pv: context.playerVersion,
                sid: context.sessionID,
                seq: String(videoIndex),
                r: context.referringURL,
                vpt: videoPlayType(for: isAutoplay),
                pt: context.playerType,
                cb: cachebuster(),
                app_id: context.applicationID,
                vvuid: videoViewUID,
                vcid: context.vcid?[videoIndex],
                mpid: context.mpid?[videoIndex],
                m_fwsitesection: context.siteSection,
                bft: bufferedTime.map(String.init),
                bit: averageBitrate.map(String.init),
                cvt: currentTime.map(String.init),
                vcdn: context.vcdn?[videoIndex],
                apid: context.apid,
                p_vw_sound: String(volume))))
    }
    
    func heartbeat(videoIndex: Int,
                   isAutoplay: Bool,
                   videoViewUID: String,
                   width: CGFloat,
                   height: CGFloat,
                   playedTime: TimeInterval,
                   bufferedTime: Int?,
                   averageBitrate: Double?,
                   volume: Int) {
        sendMetric(.tracking(
            TrackingPixels.Generator.heartbeat(
                pid: context.playerID,
                bid: context.playlistID,
                vid: context.videoObjectIDs[videoIndex],
                bcid: context.buyingCompanyID,
                r: context.referringURL,
                pt: context.playerType,
                pv: context.playerVersion,
                sid: context.sessionID,
                vvuid: videoViewUID,
                app_id: context.applicationID,
                cvt: String(Int(playedTime)),
                t: String(Int(playedTime)),
                seq: String(videoIndex),
                w: String(Int(width)),
                h: String(Int(height)),
                vpt: videoPlayType(for: isAutoplay),
                bft: bufferedTime.map(String.init),
                bit: averageBitrate.map(String.init),
                vcdn: context.vcdn?[videoIndex],
                cb: cachebuster(),
                m_fwsitesection: context.siteSection,
                apid: context.apid,
                p_vw_sound: String(volume))))
    }
    
    func videoImpression(videoIndex: Int,
                         isAutoplay: Bool,
                         timestamp: String?,
                         size: CGSize?) {
        sendMetric(.tracking(
            TrackingPixels.Generator.videoImpression(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                vid: context.videoObjectIDs[videoIndex],
                bid: context.playlistID,
                pt: context.playerType,
                pv: context.playerVersion,
                r: context.referringURL,
                sid: context.sessionID,
                vpt: videoPlayType(for: isAutoplay),
                ts: timestamp,
                cb: cachebuster(),
                w: size.map { String(Int($0.width)) },
                h: size.map { String(Int($0.height)) },
                vcid: context.vcid?[videoIndex],
                mpid: context.mpid?[videoIndex],
                seq: String(videoIndex),
                m_fwsitesection: context.siteSection)
            ))
    }
}

extension TrackingPixels.Reporter {
    func adViewTime(videoIndex: Int,
                    info: Ad.Metrics.Info,
                    type: Ad.Metrics.PlayType,
                    videoViewUID: String,
                    adId: String?,
                    transactionId: String?,
                    adCurrentTime: Double,
                    adDuration: Double) {
    
        sendMetric(.tracking(
            TrackingPixels.Generator.adViewTime(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                vid: context.videoObjectIDs[videoIndex],
                sid: context.sessionID,
                s: "true",
                pt: context.playerType,
                pv: context.playerVersion,
                vvuid: videoViewUID,
                txid: transactionId,
                rid: info.ruleId,
                adid: adId,
                t: formatter.string(from: adCurrentTime as NSNumber),
                r: context.referringURL,
                cb: cachebuster(),
                al: formatter.string(from: adDuration as NSNumber),
                m_fwsitesection: context.siteSection,
                cpm: info.cpm)))
    }
    
    
    func adEngineRequest(
        videoIndex: Int,
        info: Ad.Metrics.Info,
        type: Ad.Metrics.PlayType,
        transactionId: String?,
        videoViewUID: String) {
        sendMetric(.tracking(
            TrackingPixels.Generator.adEngineRequest(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                v: info.vendor,
                at: type.rawValue,
                bid: context.playlistID,
                vid: context.videoObjectIDs[videoIndex],
                pt: context.playerType,
                pv: context.playerVersion,
                ps: context.platformSupport,
                sid: context.sessionID,
                txid: transactionId,
                rid: info.ruleId,
                rcid: info.ruleCompanyId,
                r: context.referringURL,
                aen: info.name,
                vvuid: videoViewUID,
                cb: cachebuster(),
                m_fwsitesection: context.siteSection,
                cpm: info.cpm)))
    }
    
    func adEngineResponse(
        videoIndex: Int,
        info: Ad.Metrics.Info,
        type: Ad.Metrics.PlayType,
        responseStatus: Ad.Metrics.ResponseStatus?,
        responseTime: UInt?,
        timeout: Int?,
        fillType: Ad.Metrics.FillType?,
        transactionId: String?,
        videoViewUID: String) {
        sendMetric(.tracking(
            TrackingPixels.Generator.adEngineResponse(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                v: info.vendor,
                at: type.rawValue,
                ar: responseStatus?.rawValue ?? "yes",
                bid: context.playlistID,
                aert: responseTime.map(String.init),
                vid: context.videoObjectIDs[videoIndex],
                to: timeout.map(String.init),
                ft: fillType?.rawValue,
                pt: context.playerType,
                pv: context.playerVersion,
                ps: context.platformSupport,
                sid: context.sessionID,
                txid: transactionId,
                rid: info.ruleId,
                rcid: info.ruleCompanyId,
                r: context.referringURL,
                aen: info.name,
                vvuid: videoViewUID,
                cb: cachebuster(),
                m_fwsitesection: context.siteSection,
                cpm: info.cpm)))
    }
    
    func adEngineIssue(
        videoIndex: Int,
        info: Ad.Metrics.Info,
        type: Ad.Metrics.PlayType,
        errorMessage: String?,
        stage: Ad.Metrics.ExecutionStage?,
        transactionId: String?,
        adId: String?,
        videoViewUID: String) {
        sendMetric(.tracking(
            TrackingPixels.Generator.adIssue(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                v: info.vendor,
                at: type.rawValue,
                bid: context.playlistID,
                vid: context.videoObjectIDs[videoIndex],
                dt: errorMessage,
                stg: stage?.rawValue,
                pt: context.playerType,
                pv: context.playerVersion,
                ps: context.platformSupport,
                sid: context.sessionID,
                txid: transactionId,
                rid: info.ruleId,
                rcid: info.ruleCompanyId,
                r: context.referringURL,
                aen: info.name,
                vvuid: videoViewUID,
                cb: cachebuster(),
                aid: adId,
                m_fwsitesection: context.siteSection,
                cpm: info.cpm)))
    }
    
    func adEngineFlow(
        videoIndex: Int,
        info: Ad.Metrics.Info,
        type: Ad.Metrics.PlayType,
        stage: Ad.Metrics.ExecutionStage?,
        width: CGFloat?,
        height: CGFloat?,
        autoplay: Bool,
        transactionId: String?,
        adId: String?,
        videoViewUID: String) {
        sendMetric(.tracking(
            TrackingPixels.Generator.adEngineFlow(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                v: info.vendor,
                at: type.rawValue,
                bid: context.playlistID,
                vid: context.videoObjectIDs[videoIndex],
                w: width.map { String(describing: $0) },
                h: height.map { String(describing: $0) },
                ap: String(autoplay),
                stg: stage?.rawValue,
                pt: context.playerType,
                pv: context.playerVersion,
                ps: context.platformSupport,
                sid: context.sessionID,
                txid: transactionId,
                rid: info.ruleId,
                rcid: info.ruleCompanyId,
                r: context.referringURL,
                aen: info.name,
                vvuid: videoViewUID,
                cb: cachebuster(),
                aid: adId,
                m_fwsitesection: context.siteSection,
                cpm: info.cpm)))
    }
    
    func adVRMRequest(
        videoIndex: Int,
        type: Ad.Metrics.PlayType,
        sequenceNumber: Int,
        transactionId: String?,
        videoViewUID: String) {
        sendMetric(.tracking(
            TrackingPixels.Generator.adRequest(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                at: type.rawValue,
                bid: context.playlistID,
                vid: context.videoObjectIDs[videoIndex],
                asn: String(sequenceNumber),
                pt: context.playerType,
                ps: context.platformSupport,
                txid: transactionId,
                pv: context.playerVersion,
                sid: context.sessionID,
                r: context.referringURL,
                vvuid: videoViewUID,
                cb: cachebuster(),
                m_fwsitesection: context.siteSection)))
    }
    
    func mrcAdViewGroupM(videoIndex: Int,
                         info: Ad.Metrics.Info,
                         type: Ad.Metrics.PlayType,
                         autoplay: Bool,
                         videoViewUID: String) {
        sendMetric(.tracking(
            TrackingPixels.Generator.adViewability(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                v: info.vendor,
                ap: String(autoplay),
                at: type.rawValue,
                vstd: "groupm",
                vid: context.videoObjectIDs[videoIndex],
                bid: context.playlistID,
                pt: context.playerType,
                pv: context.playerVersion,
                sid: context.sessionID,
                r: context.referringURL,
                vvuid: videoViewUID,
                cb: cachebuster(),
                m_fwsitesection: context.siteSection,
                cpm: info.cpm)))
    }
    
    func adStart(info: Ad.Metrics.Info,
                 videoIndex: Int,
                 videoViewUID: String) {
        sendMetric(.advertisement(
            TrackingPixels.Generator.adStart(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                bid: context.playlistID,
                rid: info.ruleId,
                ps: context.platformSupport,
                r: context.referringURL,
                uuid: context.uuid,
                vvuid: videoViewUID,
                cb: cachebuster(),
                m_fwsitesection: context.siteSection,
                cpm: info.cpm)))
    }
    
    func adServerRequest(info: Ad.Metrics.Info,
                         videoIndex: Int,
                         videoViewUID: String) {
        sendMetric(.advertisement(
            TrackingPixels.Generator.adServerRequest(
                app_id: context.applicationID,
                bcid: context.buyingCompanyID,
                pid: context.playerID,
                bid: context.playlistID,
                rid: info.ruleId,
                ps: context.platformSupport,
                r: context.referringURL,
                uuid: context.uuid,
                vvuid: videoViewUID,
                cb: cachebuster(),
                m_fwsitesection: context.siteSection,
                cpm: info.cpm)))
    }
}

extension TrackingPixels.Reporter {
    
    func intent(videoIndex: Int, videoViewUID: String, videoUrl: URL?) {
        sendMetric(.tracking(
            TrackingPixels.Generator.intent(pid: context.playerID,
                                            bid: context.playlistID,
                                            bcid: context.buyingCompanyID,
                                            sid: context.sessionID,
                                            vid: context.videoObjectIDs[videoIndex],
                                            pv: context.playerVersion,
                                            pt: context.playerType,
                                            r: context.referringURL,
                                            url: videoUrl?.absoluteString,
                                            vvuid: videoViewUID,
                                            app_id: context.applicationID,
                                            cb: cachebuster(),
                                            m_fwsitesection: context.siteSection)))
    }
    
    func start(videoIndex: Int, videoViewUID: String, intentElapsedTime: String?) {
        sendMetric(.tracking(
            TrackingPixels.Generator.start(pid: context.playerID,
                                           bid: context.playlistID,
                                           bcid: context.buyingCompanyID,
                                           sid: context.sessionID,
                                           vid: context.videoObjectIDs[videoIndex],
                                           it: intentElapsedTime,
                                           pv: context.playerVersion,
                                           pt: context.playerType,
                                           r: context.referringURL,
                                           url: nil,
                                           vvuid: videoViewUID,
                                           app_id: context.applicationID,
                                           cb: cachebuster(),
                                           m_fwsitesection: context.siteSection)))
    }
    
    func bufferingStart(videoIndex: Int,
                        videoViewUID: String,
                        intentElapsedTime: String?,
                        playedTime: TimeInterval) {
        sendMetric(.tracking(
            TrackingPixels.Generator.bufferStart(pid: context.playerID,
                                                 bid: context.playlistID,
                                                 bcid: context.buyingCompanyID,
                                                 sid: context.sessionID,
                                                 vid: context.videoObjectIDs[videoIndex],
                                                 it: intentElapsedTime,
                                                 pv: context.playerVersion,
                                                 pt: context.playerType,
                                                 r: context.referringURL,
                                                 t: formatter.string(from: playedTime as NSNumber),
                                                 url: nil,
                                                 vvuid: videoViewUID,
                                                 app_id: context.applicationID,
                                                 cb: cachebuster(),
                                                 m_fwsitesection: context.siteSection)))
    }
    
    func bufferingEnd(videoIndex: Int,
                      videoViewUID: String,
                      bufferingTime: Int,
                      playedTime: TimeInterval) {
        sendMetric(.tracking(
            TrackingPixels.Generator.bufferEnd(pid: context.playerID,
                                               bid: context.playlistID,
                                               bcid: context.buyingCompanyID,
                                               sid: context.sessionID,
                                               vid: context.videoObjectIDs[videoIndex],
                                               it: nil,
                                               bt: formatter.string(from: bufferingTime as NSNumber),
                                               pv: context.playerVersion,
                                               pt: context.playerType,
                                               r: context.referringURL,
                                               t: formatter.string(from: playedTime as NSNumber),
                                               url: nil,
                                               vvuid: videoViewUID,
                                               app_id: context.applicationID,
                                               cb: cachebuster(),
                                               m_fwsitesection: context.siteSection)))
    }
    
    func error(videoIndex: Int,
               videoViewUID: String,
               error: NSError,
               currentVideoTime: TimeInterval) {
        sendMetric(.tracking(TrackingPixels.Generator.error(pid: context.playerID,
                                                            bid: context.playlistID,
                                                            bcid: context.buyingCompanyID,
                                                            vid: context.videoObjectIDs[videoIndex],
                                                            msg: error.localizedDescription,
                                                            ec: String(error.code),
                                                            it: nil,
                                                            t: formatter.string(from: currentVideoTime as NSNumber),
                                                            r: context.referringURL,
                                                            pt: context.playerType,
                                                            pv: context.playerVersion,
                                                            sid: context.sessionID,
                                                            app_id: context.applicationID,
                                                            cb: cachebuster(),
                                                            m_fwsitesection: context.siteSection)))
    }
}

private let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 4
    formatter.minimumFractionDigits = 4
    return formatter
}()

private func videoPlayType(for type: Bool?) -> String? {
    return type.map { $0 ? "auto" : "click" }
}

private func decilePresentation(_ decile: Int) -> String {
    return String(decile)
}

private func quartilePresentation(_ quartile: Int) -> String {
    return String(quartile)
}

extension TrackingPixels.Reporter {
    func sendBeacon(urls: [URL]) {
        for url in urls {
            sendMetric(.thirdParty(url))
        }
    }
}
