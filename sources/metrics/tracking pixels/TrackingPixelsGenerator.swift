//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation 

extension TrackingPixels {
    struct Generator {
        private init() {}
    }
}

extension TrackingPixels.Generator {
    
    static func contextStarted(
        app_id: String,
		bcid: String,
		pid: String,
		bid: String? = nil,
		vid: String? = nil,
		pt: String? = nil,
		pv: String? = nil,
		sid: String? = nil,
		r: String,
		seq: String? = nil,
		vvuid: String? = nil,
		vcid: String? = nil,
		mpid: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let vid = vid { queryItems.append(URLQueryItem(name: "vid", value: vid)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        if let seq = seq { queryItems.append(URLQueryItem(name: "seq", value: seq)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        if let vcid = vcid { queryItems.append(URLQueryItem(name: "vcid", value: vcid)) }
        if let mpid = mpid { queryItems.append(URLQueryItem(name: "mpid", value: mpid)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/context-started.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func videoPlay(
        app_id: String,
		bcid: String,
		pid: String,
		vid: String,
		bid: String? = nil,
		vpt: String? = nil,
		w: String? = nil,
		h: String? = nil,
		pt: String? = nil,
		pv: String? = nil,
		sid: String? = nil,
		ts: String? = nil,
		r: String,
		seq: String? = nil,
		vvuid: String? = nil,
		vcid: String? = nil,
		mpid: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        queryItems.append(URLQueryItem(name: "vid", value: vid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let vpt = vpt { queryItems.append(URLQueryItem(name: "vpt", value: vpt)) }
        if let w = w { queryItems.append(URLQueryItem(name: "w", value: w)) }
        if let h = h { queryItems.append(URLQueryItem(name: "h", value: h)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let ts = ts { queryItems.append(URLQueryItem(name: "ts", value: ts)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        if let seq = seq { queryItems.append(URLQueryItem(name: "seq", value: seq)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        if let vcid = vcid { queryItems.append(URLQueryItem(name: "vcid", value: vcid)) }
        if let mpid = mpid { queryItems.append(URLQueryItem(name: "mpid", value: mpid)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/video-play.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func videoDeciles(
        app_id: String,
		bcid: String,
		pid: String,
		vid: String,
		d: String,
		bid: String? = nil,
		pt: String? = nil,
		pv: String? = nil,
		sid: String? = nil,
		vpt: String? = nil,
		ts: String? = nil,
		r: String,
		seq: String? = nil,
		vvuid: String? = nil,
		vcid: String? = nil,
		mpid: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        queryItems.append(URLQueryItem(name: "vid", value: vid))
        queryItems.append(URLQueryItem(name: "d", value: d))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let vpt = vpt { queryItems.append(URLQueryItem(name: "vpt", value: vpt)) }
        if let ts = ts { queryItems.append(URLQueryItem(name: "ts", value: ts)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        if let seq = seq { queryItems.append(URLQueryItem(name: "seq", value: seq)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        if let vcid = vcid { queryItems.append(URLQueryItem(name: "vcid", value: vcid)) }
        if let mpid = mpid { queryItems.append(URLQueryItem(name: "mpid", value: mpid)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/video-decile.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func videoQuartiles(
        app_id: String,
		bcid: String,
		pid: String,
		vid: String,
		q: String,
		bid: String? = nil,
		pt: String? = nil,
		pv: String? = nil,
		sid: String? = nil,
		vpt: String? = nil,
		ts: String? = nil,
		r: String,
		seq: String? = nil,
		vvuid: String? = nil,
		vcid: String? = nil,
		mpid: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        queryItems.append(URLQueryItem(name: "vid", value: vid))
        queryItems.append(URLQueryItem(name: "q", value: q))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let vpt = vpt { queryItems.append(URLQueryItem(name: "vpt", value: vpt)) }
        if let ts = ts { queryItems.append(URLQueryItem(name: "ts", value: ts)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        if let seq = seq { queryItems.append(URLQueryItem(name: "seq", value: seq)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        if let vcid = vcid { queryItems.append(URLQueryItem(name: "vcid", value: vcid)) }
        if let mpid = mpid { queryItems.append(URLQueryItem(name: "mpid", value: mpid)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/video-quartile.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func videoTime(
        app_id: String,
		bcid: String,
		pid: String,
		vid: String,
		bid: String? = nil,
		vpt: String? = nil,
		t: String? = nil,
		pct: String? = nil,
		pt: String? = nil,
		pv: String? = nil,
		sid: String? = nil,
		ts: String? = nil,
		r: String,
		seq: String? = nil,
		vvuid: String? = nil,
		vcid: String? = nil,
		mpid: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        queryItems.append(URLQueryItem(name: "vid", value: vid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let vpt = vpt { queryItems.append(URLQueryItem(name: "vpt", value: vpt)) }
        if let t = t { queryItems.append(URLQueryItem(name: "t", value: t)) }
        if let pct = pct { queryItems.append(URLQueryItem(name: "pct", value: pct)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let ts = ts { queryItems.append(URLQueryItem(name: "ts", value: ts)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        if let seq = seq { queryItems.append(URLQueryItem(name: "seq", value: seq)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        if let vcid = vcid { queryItems.append(URLQueryItem(name: "vcid", value: vcid)) }
        if let mpid = mpid { queryItems.append(URLQueryItem(name: "mpid", value: mpid)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/video-time.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func videoStats(
        app_id: String,
		bcid: String,
		pid: String,
		bid: String? = nil,
		nv: String? = nil,
		t: String? = nil,
		ac: String? = nil,
		pt: String? = nil,
		pv: String? = nil,
		sid: String? = nil,
		r: String,
		vvuid: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let nv = nv { queryItems.append(URLQueryItem(name: "nv", value: nv)) }
        if let t = t { queryItems.append(URLQueryItem(name: "t", value: t)) }
        if let ac = ac { queryItems.append(URLQueryItem(name: "ac", value: ac)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/video-stats.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func slotOpp(
        app_id: String,
		bcid: String,
		pid: String,
		at: String,
		bid: String? = nil,
		vid: String? = nil,
		slot: String,
		pt: String? = nil,
		pv: String? = nil,
		ps: String? = nil,
		sid: String? = nil,
		txid: String? = nil,
		r: String,
		vvuid: String? = nil,
		cb: String,
		s: String? = nil,
		w: String? = nil,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        queryItems.append(URLQueryItem(name: "at", value: at))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let vid = vid { queryItems.append(URLQueryItem(name: "vid", value: vid)) }
        queryItems.append(URLQueryItem(name: "slot", value: slot))
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let ps = ps { queryItems.append(URLQueryItem(name: "ps", value: ps)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let txid = txid { queryItems.append(URLQueryItem(name: "txid", value: txid)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let s = s { queryItems.append(URLQueryItem(name: "s", value: s)) }
        if let w = w { queryItems.append(URLQueryItem(name: "w", value: w)) }
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/slot-opp.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func adRequest(
        app_id: String,
		bcid: String,
		pid: String,
		at: String,
		bid: String? = nil,
		vid: String? = nil,
		asn: String? = nil,
		pt: String? = nil,
		ps: String? = nil,
		txid: String? = nil,
		pv: String? = nil,
		sid: String? = nil,
		r: String,
		vvuid: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        queryItems.append(URLQueryItem(name: "at", value: at))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let vid = vid { queryItems.append(URLQueryItem(name: "vid", value: vid)) }
        if let asn = asn { queryItems.append(URLQueryItem(name: "asn", value: asn)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let ps = ps { queryItems.append(URLQueryItem(name: "ps", value: ps)) }
        if let txid = txid { queryItems.append(URLQueryItem(name: "txid", value: txid)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/ad-request.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func adServerRequest(
        app_id: String,
		bcid: String? = nil,
		pid: String,
		bid: String? = nil,
		rid: String? = nil,
		ps: String? = nil,
		r: String? = nil,
		uuid: String? = nil,
		vvuid: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        if let bcid = bcid { queryItems.append(URLQueryItem(name: "bcid", value: bcid)) }
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let rid = rid { queryItems.append(URLQueryItem(name: "rid", value: rid)) }
        if let ps = ps { queryItems.append(URLQueryItem(name: "ps", value: ps)) }
        if let r = r { queryItems.append(URLQueryItem(name: "r", value: r)) }
        if let uuid = uuid { queryItems.append(URLQueryItem(name: "uuid", value: uuid)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "ads/ad-request.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func adIssue(
        app_id: String,
		bcid: String,
		pid: String,
		v: String,
		at: String,
		bid: String? = nil,
		vid: String? = nil,
		dt: String? = nil,
		stg: String? = nil,
		pt: String? = nil,
		pv: String? = nil,
		ps: String? = nil,
		sid: String? = nil,
		txid: String? = nil,
		rid: String? = nil,
		rcid: String? = nil,
		r: String,
		aen: String? = nil,
		vvuid: String? = nil,
		cb: String,
		aid: String? = nil,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        queryItems.append(URLQueryItem(name: "v", value: v))
        queryItems.append(URLQueryItem(name: "at", value: at))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let vid = vid { queryItems.append(URLQueryItem(name: "vid", value: vid)) }
        if let dt = dt { queryItems.append(URLQueryItem(name: "dt", value: dt)) }
        if let stg = stg { queryItems.append(URLQueryItem(name: "stg", value: stg)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let ps = ps { queryItems.append(URLQueryItem(name: "ps", value: ps)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let txid = txid { queryItems.append(URLQueryItem(name: "txid", value: txid)) }
        if let rid = rid { queryItems.append(URLQueryItem(name: "rid", value: rid)) }
        if let rcid = rcid { queryItems.append(URLQueryItem(name: "rcid", value: rcid)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        if let aen = aen { queryItems.append(URLQueryItem(name: "aen", value: aen)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let aid = aid { queryItems.append(URLQueryItem(name: "aid", value: aid)) }
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/ad-issue.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func adViewTime(
        app_id: String,
		bcid: String,
		bid: String? = nil,
		pid: String,
		vid: String? = nil,
		sid: String? = nil,
		s: String? = nil,
		pt: String? = nil,
		pv: String? = nil,
		vvuid: String? = nil,
		txid: String? = nil,
		rid: String? = nil,
		adid: String? = nil,
		t: String? = nil,
		r: String,
		cb: String,
		al: String? = nil,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        if let vid = vid { queryItems.append(URLQueryItem(name: "vid", value: vid)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let s = s { queryItems.append(URLQueryItem(name: "s", value: s)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        if let txid = txid { queryItems.append(URLQueryItem(name: "txid", value: txid)) }
        if let rid = rid { queryItems.append(URLQueryItem(name: "rid", value: rid)) }
        if let adid = adid { queryItems.append(URLQueryItem(name: "adid", value: adid)) }
        if let t = t { queryItems.append(URLQueryItem(name: "t", value: t)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let al = al { queryItems.append(URLQueryItem(name: "al", value: al)) }
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/ad-view-time.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func adEngineRequest(
        app_id: String,
		bcid: String,
		pid: String,
		v: String,
		at: String,
		bid: String? = nil,
		vid: String? = nil,
		pt: String? = nil,
		pv: String? = nil,
		ps: String? = nil,
		sid: String? = nil,
		txid: String? = nil,
		rid: String? = nil,
		rcid: String? = nil,
		r: String,
		aen: String? = nil,
		vvuid: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        queryItems.append(URLQueryItem(name: "v", value: v))
        queryItems.append(URLQueryItem(name: "at", value: at))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let vid = vid { queryItems.append(URLQueryItem(name: "vid", value: vid)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let ps = ps { queryItems.append(URLQueryItem(name: "ps", value: ps)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let txid = txid { queryItems.append(URLQueryItem(name: "txid", value: txid)) }
        if let rid = rid { queryItems.append(URLQueryItem(name: "rid", value: rid)) }
        if let rcid = rcid { queryItems.append(URLQueryItem(name: "rcid", value: rcid)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        if let aen = aen { queryItems.append(URLQueryItem(name: "aen", value: aen)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/ad-engine-request.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func adEngineResponse(
        app_id: String,
		bcid: String,
		pid: String,
		v: String,
		at: String,
		ar: String,
		bid: String? = nil,
		aert: String? = nil,
		vid: String? = nil,
		to: String? = nil,
		ft: String? = nil,
		pt: String? = nil,
		pv: String? = nil,
		ps: String? = nil,
		sid: String? = nil,
		txid: String? = nil,
		rid: String? = nil,
		rcid: String? = nil,
		r: String,
		aen: String? = nil,
		vvuid: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        queryItems.append(URLQueryItem(name: "v", value: v))
        queryItems.append(URLQueryItem(name: "at", value: at))
        queryItems.append(URLQueryItem(name: "ar", value: ar))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let aert = aert { queryItems.append(URLQueryItem(name: "aert", value: aert)) }
        if let vid = vid { queryItems.append(URLQueryItem(name: "vid", value: vid)) }
        if let to = to { queryItems.append(URLQueryItem(name: "to", value: to)) }
        if let ft = ft { queryItems.append(URLQueryItem(name: "ft", value: ft)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let ps = ps { queryItems.append(URLQueryItem(name: "ps", value: ps)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let txid = txid { queryItems.append(URLQueryItem(name: "txid", value: txid)) }
        if let rid = rid { queryItems.append(URLQueryItem(name: "rid", value: rid)) }
        if let rcid = rcid { queryItems.append(URLQueryItem(name: "rcid", value: rcid)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        if let aen = aen { queryItems.append(URLQueryItem(name: "aen", value: aen)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/ad-engine-response.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func adEngineFlow(
        app_id: String,
		bcid: String,
		pid: String,
		v: String,
		at: String,
		bid: String? = nil,
		vid: String? = nil,
		w: String? = nil,
		h: String? = nil,
		ap: String,
		stg: String? = nil,
		pt: String? = nil,
		pv: String? = nil,
		ps: String? = nil,
		sid: String? = nil,
		txid: String? = nil,
		rid: String? = nil,
		rcid: String? = nil,
		r: String,
		aen: String? = nil,
		vvuid: String? = nil,
		cb: String,
		aid: String? = nil,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        queryItems.append(URLQueryItem(name: "v", value: v))
        queryItems.append(URLQueryItem(name: "at", value: at))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let vid = vid { queryItems.append(URLQueryItem(name: "vid", value: vid)) }
        if let w = w { queryItems.append(URLQueryItem(name: "w", value: w)) }
        if let h = h { queryItems.append(URLQueryItem(name: "h", value: h)) }
        queryItems.append(URLQueryItem(name: "ap", value: ap))
        if let stg = stg { queryItems.append(URLQueryItem(name: "stg", value: stg)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let ps = ps { queryItems.append(URLQueryItem(name: "ps", value: ps)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let txid = txid { queryItems.append(URLQueryItem(name: "txid", value: txid)) }
        if let rid = rid { queryItems.append(URLQueryItem(name: "rid", value: rid)) }
        if let rcid = rcid { queryItems.append(URLQueryItem(name: "rcid", value: rcid)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        if let aen = aen { queryItems.append(URLQueryItem(name: "aen", value: aen)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let aid = aid { queryItems.append(URLQueryItem(name: "aid", value: aid)) }
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/ad-engine-flow.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func adViewability(
        app_id: String,
		bcid: String,
		pid: String,
		v: String,
		ap: String,
		at: String,
		vstd: String,
		vid: String? = nil,
		bid: String? = nil,
		pt: String? = nil,
		pv: String? = nil,
		sid: String? = nil,
		r: String,
		vvuid: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        queryItems.append(URLQueryItem(name: "v", value: v))
        queryItems.append(URLQueryItem(name: "ap", value: ap))
        queryItems.append(URLQueryItem(name: "at", value: at))
        queryItems.append(URLQueryItem(name: "vstd", value: vstd))
        if let vid = vid { queryItems.append(URLQueryItem(name: "vid", value: vid)) }
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/mrc-ad-view.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func impressions(
        app_id: String,
		bcid: String,
		pid: String,
		bid: String? = nil,
		pt: String? = nil,
		sid: String? = nil,
		r: String,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/impression.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func videoImpression(
        app_id: String,
		bcid: String,
		pid: String,
		vid: String,
		bid: String? = nil,
		pt: String? = nil,
		pv: String? = nil,
		r: String,
		sid: String? = nil,
		vpt: String? = nil,
		ts: String? = nil,
		cb: String,
		w: String? = nil,
		h: String? = nil,
		vcid: String? = nil,
		mpid: String? = nil,
		seq: String? = nil,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        queryItems.append(URLQueryItem(name: "vid", value: vid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let vpt = vpt { queryItems.append(URLQueryItem(name: "vpt", value: vpt)) }
        if let ts = ts { queryItems.append(URLQueryItem(name: "ts", value: ts)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let w = w { queryItems.append(URLQueryItem(name: "w", value: w)) }
        if let h = h { queryItems.append(URLQueryItem(name: "h", value: h)) }
        if let vcid = vcid { queryItems.append(URLQueryItem(name: "vcid", value: vcid)) }
        if let mpid = mpid { queryItems.append(URLQueryItem(name: "mpid", value: mpid)) }
        if let seq = seq { queryItems.append(URLQueryItem(name: "seq", value: seq)) }
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/video-impression.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func displays(
        app_id: String,
		bcid: String,
		pid: String,
		bid: String? = nil,
		sid: String? = nil,
		dt: String? = nil,
		w: String? = nil,
		h: String? = nil,
		pt: String? = nil,
		pv: String? = nil,
		r: String,
		vvuid: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let dt = dt { queryItems.append(URLQueryItem(name: "dt", value: dt)) }
        if let w = w { queryItems.append(URLQueryItem(name: "w", value: w)) }
        if let h = h { queryItems.append(URLQueryItem(name: "h", value: h)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        queryItems.append(URLQueryItem(name: "r", value: r))
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "trk/display.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func adStart(
        app_id: String,
		bcid: String? = nil,
		pid: String,
		bid: String? = nil,
		rid: String? = nil,
		ps: String? = nil,
		r: String? = nil,
		uuid: String? = nil,
		vvuid: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        if let bcid = bcid { queryItems.append(URLQueryItem(name: "bcid", value: bcid)) }
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let rid = rid { queryItems.append(URLQueryItem(name: "rid", value: rid)) }
        if let ps = ps { queryItems.append(URLQueryItem(name: "ps", value: ps)) }
        if let r = r { queryItems.append(URLQueryItem(name: "r", value: r)) }
        if let uuid = uuid { queryItems.append(URLQueryItem(name: "uuid", value: uuid)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "ads/ad-start.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func video3Sec(
        bid: String? = nil,
		pid: String,
		bcid: String,
		vid: String,
		pv: String? = nil,
		sid: String? = nil,
		seq: String? = nil,
		r: String? = nil,
		vpt: String? = nil,
		pt: String? = nil,
		cb: String,
		app_id: String,
		vvuid: String? = nil,
		vcid: String? = nil,
		mpid: String? = nil,
		m_fwsitesection: String? = nil,
		bft: String? = nil,
		bit: String? = nil,
		cvt: String? = nil,
		vcdn: String? = nil,
		apid: String? = nil,
		p_vw_sound: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        queryItems.append(URLQueryItem(name: "vid", value: vid))
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let seq = seq { queryItems.append(URLQueryItem(name: "seq", value: seq)) }
        if let r = r { queryItems.append(URLQueryItem(name: "r", value: r)) }
        if let vpt = vpt { queryItems.append(URLQueryItem(name: "vpt", value: vpt)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        queryItems.append(URLQueryItem(name: "app_id", value: app_id))
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        if let vcid = vcid { queryItems.append(URLQueryItem(name: "vcid", value: vcid)) }
        if let mpid = mpid { queryItems.append(URLQueryItem(name: "mpid", value: mpid)) }
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        if let bft = bft { queryItems.append(URLQueryItem(name: "bft", value: bft)) }
        if let bit = bit { queryItems.append(URLQueryItem(name: "bit", value: bit)) }
        if let cvt = cvt { queryItems.append(URLQueryItem(name: "cvt", value: cvt)) }
        if let vcdn = vcdn { queryItems.append(URLQueryItem(name: "vcdn", value: vcdn)) }
        if let apid = apid { queryItems.append(URLQueryItem(name: "apid", value: apid)) }
        if let p_vw_sound = p_vw_sound { queryItems.append(URLQueryItem(name: "p.vw.sound", value: p_vw_sound)) }
        
        var components = URLComponents()
        components.path = "trk/video-3sec.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func heartbeat(
        pid: String,
		bid: String? = nil,
		vid: String? = nil,
		bcid: String,
		r: String? = nil,
		pt: String? = nil,
		pv: String? = nil,
		sid: String? = nil,
		vvuid: String? = nil,
		app_id: String? = nil,
		cvt: String? = nil,
		t: String? = nil,
		seq: String? = nil,
		w: String? = nil,
		h: String? = nil,
		vpt: String? = nil,
		bft: String? = nil,
		bit: String? = nil,
		vcdn: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil,
		apid: String? = nil,
		p_vw_sound: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        if let vid = vid { queryItems.append(URLQueryItem(name: "vid", value: vid)) }
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        if let r = r { queryItems.append(URLQueryItem(name: "r", value: r)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        if let app_id = app_id { queryItems.append(URLQueryItem(name: "app_id", value: app_id)) }
        if let cvt = cvt { queryItems.append(URLQueryItem(name: "cvt", value: cvt)) }
        if let t = t { queryItems.append(URLQueryItem(name: "t", value: t)) }
        if let seq = seq { queryItems.append(URLQueryItem(name: "seq", value: seq)) }
        if let w = w { queryItems.append(URLQueryItem(name: "w", value: w)) }
        if let h = h { queryItems.append(URLQueryItem(name: "h", value: h)) }
        if let vpt = vpt { queryItems.append(URLQueryItem(name: "vpt", value: vpt)) }
        if let bft = bft { queryItems.append(URLQueryItem(name: "bft", value: bft)) }
        if let bit = bit { queryItems.append(URLQueryItem(name: "bit", value: bit)) }
        if let vcdn = vcdn { queryItems.append(URLQueryItem(name: "vcdn", value: vcdn)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        if let apid = apid { queryItems.append(URLQueryItem(name: "apid", value: apid)) }
        if let p_vw_sound = p_vw_sound { queryItems.append(URLQueryItem(name: "p.vw.sound", value: p_vw_sound)) }
        
        var components = URLComponents()
        components.path = "lstr/heartbeat.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func intent(
        pid: String,
		bid: String? = nil,
		bcid: String,
		sid: String? = nil,
		vid: String? = nil,
		pv: String? = nil,
		pt: String? = nil,
		r: String? = nil,
		url: String? = nil,
		vvuid: String? = nil,
		it: String? = nil,
		app_id: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let vid = vid { queryItems.append(URLQueryItem(name: "vid", value: vid)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let r = r { queryItems.append(URLQueryItem(name: "r", value: r)) }
        if let url = url { queryItems.append(URLQueryItem(name: "url", value: url)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        if let it = it { queryItems.append(URLQueryItem(name: "it", value: it)) }
        if let app_id = app_id { queryItems.append(URLQueryItem(name: "app_id", value: app_id)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "qoe/intent.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func start(
        pid: String,
		bid: String? = nil,
		bcid: String,
		sid: String? = nil,
		vid: String? = nil,
		it: String? = nil,
		pv: String? = nil,
		pt: String? = nil,
		r: String? = nil,
		url: String? = nil,
		vvuid: String? = nil,
		app_id: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let vid = vid { queryItems.append(URLQueryItem(name: "vid", value: vid)) }
        if let it = it { queryItems.append(URLQueryItem(name: "it", value: it)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let r = r { queryItems.append(URLQueryItem(name: "r", value: r)) }
        if let url = url { queryItems.append(URLQueryItem(name: "url", value: url)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        if let app_id = app_id { queryItems.append(URLQueryItem(name: "app_id", value: app_id)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "qoe/start.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func error(
        pid: String,
		bid: String? = nil,
		bcid: String,
		vid: String? = nil,
		msg: String? = nil,
		ec: String? = nil,
		it: String? = nil,
		t: String? = nil,
		r: String? = nil,
		url: String? = nil,
		pt: String? = nil,
		pv: String? = nil,
		sid: String? = nil,
		app_id: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        if let vid = vid { queryItems.append(URLQueryItem(name: "vid", value: vid)) }
        if let msg = msg { queryItems.append(URLQueryItem(name: "msg", value: msg)) }
        if let ec = ec { queryItems.append(URLQueryItem(name: "ec", value: ec)) }
        if let it = it { queryItems.append(URLQueryItem(name: "it", value: it)) }
        if let t = t { queryItems.append(URLQueryItem(name: "t", value: t)) }
        if let r = r { queryItems.append(URLQueryItem(name: "r", value: r)) }
        if let url = url { queryItems.append(URLQueryItem(name: "url", value: url)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let app_id = app_id { queryItems.append(URLQueryItem(name: "app_id", value: app_id)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "qoe/error.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func rayLoad(
        pid: String,
		bid: String? = nil,
		bcid: String,
		sid: String? = nil,
		vid: String? = nil,
		it: String? = nil,
		pv: String? = nil,
		pt: String? = nil,
		r: String? = nil,
		t: String? = nil,
		url: String? = nil,
		lvl: String? = nil,
		vvuid: String? = nil,
		app_id: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let vid = vid { queryItems.append(URLQueryItem(name: "vid", value: vid)) }
        if let it = it { queryItems.append(URLQueryItem(name: "it", value: it)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let r = r { queryItems.append(URLQueryItem(name: "r", value: r)) }
        if let t = t { queryItems.append(URLQueryItem(name: "t", value: t)) }
        if let url = url { queryItems.append(URLQueryItem(name: "url", value: url)) }
        if let lvl = lvl { queryItems.append(URLQueryItem(name: "lvl", value: lvl)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        if let app_id = app_id { queryItems.append(URLQueryItem(name: "app_id", value: app_id)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "qoe/ray-load.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func bufferStart(
        pid: String,
		bid: String? = nil,
		bcid: String,
		sid: String? = nil,
		vid: String? = nil,
		it: String? = nil,
		pv: String? = nil,
		pt: String? = nil,
		r: String? = nil,
		t: String? = nil,
		url: String? = nil,
		vvuid: String? = nil,
		app_id: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let vid = vid { queryItems.append(URLQueryItem(name: "vid", value: vid)) }
        if let it = it { queryItems.append(URLQueryItem(name: "it", value: it)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let r = r { queryItems.append(URLQueryItem(name: "r", value: r)) }
        if let t = t { queryItems.append(URLQueryItem(name: "t", value: t)) }
        if let url = url { queryItems.append(URLQueryItem(name: "url", value: url)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        if let app_id = app_id { queryItems.append(URLQueryItem(name: "app_id", value: app_id)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "qoe/buffer-start.gif"
        components.queryItems = queryItems
        
        return components
    }
    
    static func bufferEnd(
        pid: String,
		bid: String? = nil,
		bcid: String,
		sid: String? = nil,
		vid: String? = nil,
		it: String? = nil,
		bt: String? = nil,
		pv: String? = nil,
		pt: String? = nil,
		r: String? = nil,
		t: String? = nil,
		url: String? = nil,
		vvuid: String? = nil,
		app_id: String? = nil,
		cb: String,
		m_fwsitesection: String? = nil) -> URLComponents
    {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "pid", value: pid))
        if let bid = bid { queryItems.append(URLQueryItem(name: "bid", value: bid)) }
        queryItems.append(URLQueryItem(name: "bcid", value: bcid))
        if let sid = sid { queryItems.append(URLQueryItem(name: "sid", value: sid)) }
        if let vid = vid { queryItems.append(URLQueryItem(name: "vid", value: vid)) }
        if let it = it { queryItems.append(URLQueryItem(name: "it", value: it)) }
        if let bt = bt { queryItems.append(URLQueryItem(name: "bt", value: bt)) }
        if let pv = pv { queryItems.append(URLQueryItem(name: "pv", value: pv)) }
        if let pt = pt { queryItems.append(URLQueryItem(name: "pt", value: pt)) }
        if let r = r { queryItems.append(URLQueryItem(name: "r", value: r)) }
        if let t = t { queryItems.append(URLQueryItem(name: "t", value: t)) }
        if let url = url { queryItems.append(URLQueryItem(name: "url", value: url)) }
        if let vvuid = vvuid { queryItems.append(URLQueryItem(name: "vvuid", value: vvuid)) }
        if let app_id = app_id { queryItems.append(URLQueryItem(name: "app_id", value: app_id)) }
        queryItems.append(URLQueryItem(name: "cb", value: cb))
        if let m_fwsitesection = m_fwsitesection { queryItems.append(URLQueryItem(name: "m.fwsitesection", value: m_fwsitesection)) }
        
        var components = URLComponents()
        components.path = "qoe/buffer-end.gif"
        components.queryItems = queryItems
        
        return components
    }
    
}
