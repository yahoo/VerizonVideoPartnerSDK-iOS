//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import XCTest
@testable import VerizonVideoPartnerSDK 


class TrackingPixelsGeneratorTests: XCTestCase {

func testcontextStarted()
{
    let pixel = TrackingPixels.Generator.contextStarted(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		bid: "bid",
		vid: "vid",
		pt: "pt",
		pv: "pv",
		sid: "sid",
		r: "r",
		seq: "seq",
		vvuid: "vvuid",
		vcid: "vcid",
		mpid: "mpid",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		bckt: "bckt",
		expn: "expn",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "seq", value: "seq")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "vcid", value: "vcid")))
    XCTAssertTrue(query.contains(.init(name: "mpid", value: "mpid")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "bckt", value: "bckt")))
    XCTAssertTrue(query.contains(.init(name: "expn", value: "expn")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testvideoPlay()
{
    let pixel = TrackingPixels.Generator.videoPlay(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		vid: "vid",
		bid: "bid",
		vpt: "vpt",
		w: "w",
		h: "h",
		pt: "pt",
		pv: "pv",
		sid: "sid",
		ts: "ts",
		r: "r",
		seq: "seq",
		vvuid: "vvuid",
		vcid: "vcid",
		mpid: "mpid",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		bckt: "bckt",
		expn: "expn",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "vpt", value: "vpt")))
    XCTAssertTrue(query.contains(.init(name: "w", value: "w")))
    XCTAssertTrue(query.contains(.init(name: "h", value: "h")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "ts", value: "ts")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "seq", value: "seq")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "vcid", value: "vcid")))
    XCTAssertTrue(query.contains(.init(name: "mpid", value: "mpid")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "bckt", value: "bckt")))
    XCTAssertTrue(query.contains(.init(name: "expn", value: "expn")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testvideoDeciles()
{
    let pixel = TrackingPixels.Generator.videoDeciles(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		vid: "vid",
		d: "d",
		bid: "bid",
		pt: "pt",
		pv: "pv",
		sid: "sid",
		vpt: "vpt",
		ts: "ts",
		r: "r",
		seq: "seq",
		vvuid: "vvuid",
		vcid: "vcid",
		mpid: "mpid",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "d", value: "d")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "vpt", value: "vpt")))
    XCTAssertTrue(query.contains(.init(name: "ts", value: "ts")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "seq", value: "seq")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "vcid", value: "vcid")))
    XCTAssertTrue(query.contains(.init(name: "mpid", value: "mpid")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testvideoQuartiles()
{
    let pixel = TrackingPixels.Generator.videoQuartiles(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		vid: "vid",
		q: "q",
		bid: "bid",
		pt: "pt",
		pv: "pv",
		sid: "sid",
		vpt: "vpt",
		ts: "ts",
		r: "r",
		seq: "seq",
		vvuid: "vvuid",
		vcid: "vcid",
		mpid: "mpid",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		bckt: "bckt",
		expn: "expn",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "q", value: "q")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "vpt", value: "vpt")))
    XCTAssertTrue(query.contains(.init(name: "ts", value: "ts")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "seq", value: "seq")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "vcid", value: "vcid")))
    XCTAssertTrue(query.contains(.init(name: "mpid", value: "mpid")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "bckt", value: "bckt")))
    XCTAssertTrue(query.contains(.init(name: "expn", value: "expn")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testvideoTime()
{
    let pixel = TrackingPixels.Generator.videoTime(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		vid: "vid",
		bid: "bid",
		vpt: "vpt",
		t: "t",
		pct: "pct",
		pt: "pt",
		pv: "pv",
		sid: "sid",
		ts: "ts",
		r: "r",
		seq: "seq",
		vvuid: "vvuid",
		vcid: "vcid",
		mpid: "mpid",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "vpt", value: "vpt")))
    XCTAssertTrue(query.contains(.init(name: "t", value: "t")))
    XCTAssertTrue(query.contains(.init(name: "pct", value: "pct")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "ts", value: "ts")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "seq", value: "seq")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "vcid", value: "vcid")))
    XCTAssertTrue(query.contains(.init(name: "mpid", value: "mpid")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testvideoStats()
{
    let pixel = TrackingPixels.Generator.videoStats(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		bid: "bid",
		nv: "nv",
		t: "t",
		ac: "ac",
		pt: "pt",
		pv: "pv",
		sid: "sid",
		r: "r",
		vvuid: "vvuid",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "nv", value: "nv")))
    XCTAssertTrue(query.contains(.init(name: "t", value: "t")))
    XCTAssertTrue(query.contains(.init(name: "ac", value: "ac")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testslotOpp()
{
    let pixel = TrackingPixels.Generator.slotOpp(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		at: "at",
		bid: "bid",
		vid: "vid",
		slot: "slot",
		pt: "pt",
		pv: "pv",
		ps: "ps",
		sid: "sid",
		txid: "txid",
		r: "r",
		vvuid: "vvuid",
		cb: "cb",
		s: "s",
		w: "w",
		m_fwsitesection: "m_fwsitesection",
		poid: "poid",
		adseq: "adseq",
		bckt: "bckt",
		expn: "expn",
		pblob_id: "pblob_id",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "at", value: "at")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "slot", value: "slot")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "ps", value: "ps")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "txid", value: "txid")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "s", value: "s")))
    XCTAssertTrue(query.contains(.init(name: "w", value: "w")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "poid", value: "poid")))
    XCTAssertTrue(query.contains(.init(name: "adseq", value: "adseq")))
    XCTAssertTrue(query.contains(.init(name: "bckt", value: "bckt")))
    XCTAssertTrue(query.contains(.init(name: "expn", value: "expn")))
    XCTAssertTrue(query.contains(.init(name: "pblob_id", value: "pblob_id")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testadRequest()
{
    let pixel = TrackingPixels.Generator.adRequest(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		at: "at",
		bid: "bid",
		vid: "vid",
		asn: "asn",
		pt: "pt",
		ps: "ps",
		txid: "txid",
		pv: "pv",
		sid: "sid",
		r: "r",
		vvuid: "vvuid",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		bckt: "bckt",
		expn: "expn",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "at", value: "at")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "asn", value: "asn")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "ps", value: "ps")))
    XCTAssertTrue(query.contains(.init(name: "txid", value: "txid")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "bckt", value: "bckt")))
    XCTAssertTrue(query.contains(.init(name: "expn", value: "expn")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testadServerRequest()
{
    let pixel = TrackingPixels.Generator.adServerRequest(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		bid: "bid",
		rid: "rid",
		ps: "ps",
		r: "r",
		uuid: "uuid",
		vvuid: "vvuid",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		bckt: "bckt",
		expn: "expn",
		cpm: "cpm",
		pblob_id: "pblob_id",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "rid", value: "rid")))
    XCTAssertTrue(query.contains(.init(name: "ps", value: "ps")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "uuid", value: "uuid")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "bckt", value: "bckt")))
    XCTAssertTrue(query.contains(.init(name: "expn", value: "expn")))
    XCTAssertTrue(query.contains(.init(name: "cpm", value: "cpm")))
    XCTAssertTrue(query.contains(.init(name: "pblob_id", value: "pblob_id")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testadIssue()
{
    let pixel = TrackingPixels.Generator.adIssue(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		v: "v",
		at: "at",
		bid: "bid",
		vid: "vid",
		dt: "dt",
		stg: "stg",
		pt: "pt",
		pv: "pv",
		ps: "ps",
		sid: "sid",
		txid: "txid",
		rid: "rid",
		rcid: "rcid",
		r: "r",
		aen: "aen",
		vvuid: "vvuid",
		cb: "cb",
		aid: "aid",
		m_fwsitesection: "m_fwsitesection",
		poid: "poid",
		adseq: "adseq",
		bckt: "bckt",
		expn: "expn",
		cpm: "cpm",
		pblob_id: "pblob_id",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "v", value: "v")))
    XCTAssertTrue(query.contains(.init(name: "at", value: "at")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "dt", value: "dt")))
    XCTAssertTrue(query.contains(.init(name: "stg", value: "stg")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "ps", value: "ps")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "txid", value: "txid")))
    XCTAssertTrue(query.contains(.init(name: "rid", value: "rid")))
    XCTAssertTrue(query.contains(.init(name: "rcid", value: "rcid")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "aen", value: "aen")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "aid", value: "aid")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "poid", value: "poid")))
    XCTAssertTrue(query.contains(.init(name: "adseq", value: "adseq")))
    XCTAssertTrue(query.contains(.init(name: "bckt", value: "bckt")))
    XCTAssertTrue(query.contains(.init(name: "expn", value: "expn")))
    XCTAssertTrue(query.contains(.init(name: "cpm", value: "cpm")))
    XCTAssertTrue(query.contains(.init(name: "pblob_id", value: "pblob_id")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testadViewTime()
{
    let pixel = TrackingPixels.Generator.adViewTime(
        app_id: "app_id",
		bcid: "bcid",
		bid: "bid",
		pid: "pid",
		vid: "vid",
		sid: "sid",
		s: "s",
		pt: "pt",
		pv: "pv",
		vvuid: "vvuid",
		txid: "txid",
		rid: "rid",
		adid: "adid",
		t: "t",
		r: "r",
		cb: "cb",
		al: "al",
		m_fwsitesection: "m_fwsitesection",
		poid: "poid",
		adseq: "adseq",
		bckt: "bckt",
		expn: "expn",
		cpm: "cpm",
		pblob_id: "pblob_id",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "s", value: "s")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "txid", value: "txid")))
    XCTAssertTrue(query.contains(.init(name: "rid", value: "rid")))
    XCTAssertTrue(query.contains(.init(name: "adid", value: "adid")))
    XCTAssertTrue(query.contains(.init(name: "t", value: "t")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "al", value: "al")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "poid", value: "poid")))
    XCTAssertTrue(query.contains(.init(name: "adseq", value: "adseq")))
    XCTAssertTrue(query.contains(.init(name: "bckt", value: "bckt")))
    XCTAssertTrue(query.contains(.init(name: "expn", value: "expn")))
    XCTAssertTrue(query.contains(.init(name: "cpm", value: "cpm")))
    XCTAssertTrue(query.contains(.init(name: "pblob_id", value: "pblob_id")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testadEngineRequest()
{
    let pixel = TrackingPixels.Generator.adEngineRequest(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		v: "v",
		at: "at",
		bid: "bid",
		vid: "vid",
		pt: "pt",
		pv: "pv",
		ps: "ps",
		sid: "sid",
		txid: "txid",
		rid: "rid",
		rcid: "rcid",
		r: "r",
		aen: "aen",
		vvuid: "vvuid",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		poid: "poid",
		adseq: "adseq",
		bckt: "bckt",
		expn: "expn",
		cpm: "cpm",
		pblob_id: "pblob_id",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "v", value: "v")))
    XCTAssertTrue(query.contains(.init(name: "at", value: "at")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "ps", value: "ps")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "txid", value: "txid")))
    XCTAssertTrue(query.contains(.init(name: "rid", value: "rid")))
    XCTAssertTrue(query.contains(.init(name: "rcid", value: "rcid")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "aen", value: "aen")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "poid", value: "poid")))
    XCTAssertTrue(query.contains(.init(name: "adseq", value: "adseq")))
    XCTAssertTrue(query.contains(.init(name: "bckt", value: "bckt")))
    XCTAssertTrue(query.contains(.init(name: "expn", value: "expn")))
    XCTAssertTrue(query.contains(.init(name: "cpm", value: "cpm")))
    XCTAssertTrue(query.contains(.init(name: "pblob_id", value: "pblob_id")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testadEngineResponse()
{
    let pixel = TrackingPixels.Generator.adEngineResponse(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		v: "v",
		at: "at",
		ar: "ar",
		bid: "bid",
		aert: "aert",
		vid: "vid",
		to: "to",
		ft: "ft",
		pt: "pt",
		pv: "pv",
		ps: "ps",
		sid: "sid",
		txid: "txid",
		rid: "rid",
		rcid: "rcid",
		r: "r",
		aen: "aen",
		vvuid: "vvuid",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		poid: "poid",
		adseq: "adseq",
		bckt: "bckt",
		expn: "expn",
		cpm: "cpm",
		pblob_id: "pblob_id",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "v", value: "v")))
    XCTAssertTrue(query.contains(.init(name: "at", value: "at")))
    XCTAssertTrue(query.contains(.init(name: "ar", value: "ar")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "aert", value: "aert")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "to", value: "to")))
    XCTAssertTrue(query.contains(.init(name: "ft", value: "ft")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "ps", value: "ps")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "txid", value: "txid")))
    XCTAssertTrue(query.contains(.init(name: "rid", value: "rid")))
    XCTAssertTrue(query.contains(.init(name: "rcid", value: "rcid")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "aen", value: "aen")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "poid", value: "poid")))
    XCTAssertTrue(query.contains(.init(name: "adseq", value: "adseq")))
    XCTAssertTrue(query.contains(.init(name: "bckt", value: "bckt")))
    XCTAssertTrue(query.contains(.init(name: "expn", value: "expn")))
    XCTAssertTrue(query.contains(.init(name: "cpm", value: "cpm")))
    XCTAssertTrue(query.contains(.init(name: "pblob_id", value: "pblob_id")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testadEngineFlow()
{
    let pixel = TrackingPixels.Generator.adEngineFlow(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		v: "v",
		at: "at",
		bid: "bid",
		vid: "vid",
		w: "w",
		h: "h",
		ap: "ap",
		stg: "stg",
		pt: "pt",
		pv: "pv",
		ps: "ps",
		sid: "sid",
		txid: "txid",
		rid: "rid",
		rcid: "rcid",
		r: "r",
		aen: "aen",
		vvuid: "vvuid",
		cb: "cb",
		aid: "aid",
		m_fwsitesection: "m_fwsitesection",
		poid: "poid",
		adseq: "adseq",
		bckt: "bckt",
		expn: "expn",
		cpm: "cpm",
		pblob_id: "pblob_id",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "v", value: "v")))
    XCTAssertTrue(query.contains(.init(name: "at", value: "at")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "w", value: "w")))
    XCTAssertTrue(query.contains(.init(name: "h", value: "h")))
    XCTAssertTrue(query.contains(.init(name: "ap", value: "ap")))
    XCTAssertTrue(query.contains(.init(name: "stg", value: "stg")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "ps", value: "ps")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "txid", value: "txid")))
    XCTAssertTrue(query.contains(.init(name: "rid", value: "rid")))
    XCTAssertTrue(query.contains(.init(name: "rcid", value: "rcid")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "aen", value: "aen")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "aid", value: "aid")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "poid", value: "poid")))
    XCTAssertTrue(query.contains(.init(name: "adseq", value: "adseq")))
    XCTAssertTrue(query.contains(.init(name: "bckt", value: "bckt")))
    XCTAssertTrue(query.contains(.init(name: "expn", value: "expn")))
    XCTAssertTrue(query.contains(.init(name: "cpm", value: "cpm")))
    XCTAssertTrue(query.contains(.init(name: "pblob_id", value: "pblob_id")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testadViewability()
{
    let pixel = TrackingPixels.Generator.adViewability(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		v: "v",
		ap: "ap",
		at: "at",
		vstd: "vstd",
		vid: "vid",
		bid: "bid",
		pt: "pt",
		pv: "pv",
		sid: "sid",
		r: "r",
		vvuid: "vvuid",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		poid: "poid",
		adseq: "adseq",
		bckt: "bckt",
		expn: "expn",
		cpm: "cpm",
		pblob_id: "pblob_id",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "v", value: "v")))
    XCTAssertTrue(query.contains(.init(name: "ap", value: "ap")))
    XCTAssertTrue(query.contains(.init(name: "at", value: "at")))
    XCTAssertTrue(query.contains(.init(name: "vstd", value: "vstd")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "poid", value: "poid")))
    XCTAssertTrue(query.contains(.init(name: "adseq", value: "adseq")))
    XCTAssertTrue(query.contains(.init(name: "bckt", value: "bckt")))
    XCTAssertTrue(query.contains(.init(name: "expn", value: "expn")))
    XCTAssertTrue(query.contains(.init(name: "cpm", value: "cpm")))
    XCTAssertTrue(query.contains(.init(name: "pblob_id", value: "pblob_id")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testimpressions()
{
    let pixel = TrackingPixels.Generator.impressions(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		bid: "bid",
		pt: "pt",
		sid: "sid",
		r: "r",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testvideoImpression()
{
    let pixel = TrackingPixels.Generator.videoImpression(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		vid: "vid",
		bid: "bid",
		pt: "pt",
		pv: "pv",
		r: "r",
		sid: "sid",
		vpt: "vpt",
		ts: "ts",
		cb: "cb",
		w: "w",
		h: "h",
		vcid: "vcid",
		mpid: "mpid",
		seq: "seq",
		m_fwsitesection: "m_fwsitesection",
		bckt: "bckt",
		expn: "expn",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "vpt", value: "vpt")))
    XCTAssertTrue(query.contains(.init(name: "ts", value: "ts")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "w", value: "w")))
    XCTAssertTrue(query.contains(.init(name: "h", value: "h")))
    XCTAssertTrue(query.contains(.init(name: "vcid", value: "vcid")))
    XCTAssertTrue(query.contains(.init(name: "mpid", value: "mpid")))
    XCTAssertTrue(query.contains(.init(name: "seq", value: "seq")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "bckt", value: "bckt")))
    XCTAssertTrue(query.contains(.init(name: "expn", value: "expn")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testdisplays()
{
    let pixel = TrackingPixels.Generator.displays(
        app_id: "app_id",
		bcid: "bcid",
		pid: "pid",
		bid: "bid",
		sid: "sid",
		dt: "dt",
		w: "w",
		h: "h",
		pt: "pt",
		pv: "pv",
		r: "r",
		vvuid: "vvuid",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		bckt: "bckt",
		expn: "expn",
		ab: "ab",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "dt", value: "dt")))
    XCTAssertTrue(query.contains(.init(name: "w", value: "w")))
    XCTAssertTrue(query.contains(.init(name: "h", value: "h")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "bckt", value: "bckt")))
    XCTAssertTrue(query.contains(.init(name: "expn", value: "expn")))
    XCTAssertTrue(query.contains(.init(name: "ab", value: "ab")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testadStart()
{
    let pixel = TrackingPixels.Generator.adStart(
        app_id: "app_id",
		bcid: "bcid",
		sid: "sid",
		pid: "pid",
		bid: "bid",
		rid: "rid",
		ps: "ps",
		r: "r",
		uuid: "uuid",
		vvuid: "vvuid",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		bckt: "bckt",
		expn: "expn",
		cpm: "cpm",
		pblob_id: "pblob_id",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "rid", value: "rid")))
    XCTAssertTrue(query.contains(.init(name: "ps", value: "ps")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "uuid", value: "uuid")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "bckt", value: "bckt")))
    XCTAssertTrue(query.contains(.init(name: "expn", value: "expn")))
    XCTAssertTrue(query.contains(.init(name: "cpm", value: "cpm")))
    XCTAssertTrue(query.contains(.init(name: "pblob_id", value: "pblob_id")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testvideo3Sec()
{
    let pixel = TrackingPixels.Generator.video3Sec(
        bid: "bid",
		pid: "pid",
		bcid: "bcid",
		vid: "vid",
		pv: "pv",
		sid: "sid",
		seq: "seq",
		r: "r",
		vpt: "vpt",
		pt: "pt",
		cb: "cb",
		app_id: "app_id",
		vvuid: "vvuid",
		vcid: "vcid",
		mpid: "mpid",
		m_fwsitesection: "m_fwsitesection",
		bft: "bft",
		bit: "bit",
		cvt: "cvt",
		vcdn: "vcdn",
		apid: "apid",
		p_vw_sound: "p_vw_sound",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "seq", value: "seq")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "vpt", value: "vpt")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "vcid", value: "vcid")))
    XCTAssertTrue(query.contains(.init(name: "mpid", value: "mpid")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "bft", value: "bft")))
    XCTAssertTrue(query.contains(.init(name: "bit", value: "bit")))
    XCTAssertTrue(query.contains(.init(name: "cvt", value: "cvt")))
    XCTAssertTrue(query.contains(.init(name: "vcdn", value: "vcdn")))
    XCTAssertTrue(query.contains(.init(name: "apid", value: "apid")))
    XCTAssertTrue(query.contains(.init(name: "p.vw.sound", value: "p_vw_sound")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testheartbeat()
{
    let pixel = TrackingPixels.Generator.heartbeat(
        pid: "pid",
		bid: "bid",
		vid: "vid",
		bcid: "bcid",
		r: "r",
		pt: "pt",
		pv: "pv",
		sid: "sid",
		vvuid: "vvuid",
		app_id: "app_id",
		cvt: "cvt",
		t: "t",
		seq: "seq",
		w: "w",
		h: "h",
		vpt: "vpt",
		bft: "bft",
		bit: "bit",
		vcdn: "vcdn",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		apid: "apid",
		p_vw_sound: "p_vw_sound",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "cvt", value: "cvt")))
    XCTAssertTrue(query.contains(.init(name: "t", value: "t")))
    XCTAssertTrue(query.contains(.init(name: "seq", value: "seq")))
    XCTAssertTrue(query.contains(.init(name: "w", value: "w")))
    XCTAssertTrue(query.contains(.init(name: "h", value: "h")))
    XCTAssertTrue(query.contains(.init(name: "vpt", value: "vpt")))
    XCTAssertTrue(query.contains(.init(name: "bft", value: "bft")))
    XCTAssertTrue(query.contains(.init(name: "bit", value: "bit")))
    XCTAssertTrue(query.contains(.init(name: "vcdn", value: "vcdn")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "apid", value: "apid")))
    XCTAssertTrue(query.contains(.init(name: "p.vw.sound", value: "p_vw_sound")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testintent()
{
    let pixel = TrackingPixels.Generator.intent(
        pid: "pid",
		bid: "bid",
		bcid: "bcid",
		sid: "sid",
		vid: "vid",
		pv: "pv",
		pt: "pt",
		r: "r",
		url: "url",
		vvuid: "vvuid",
		it: "it",
		app_id: "app_id",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "url", value: "url")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "it", value: "it")))
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func teststart()
{
    let pixel = TrackingPixels.Generator.start(
        pid: "pid",
		bid: "bid",
		bcid: "bcid",
		sid: "sid",
		vid: "vid",
		it: "it",
		pv: "pv",
		pt: "pt",
		r: "r",
		url: "url",
		vvuid: "vvuid",
		app_id: "app_id",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "it", value: "it")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "url", value: "url")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testerror()
{
    let pixel = TrackingPixels.Generator.error(
        pid: "pid",
		bid: "bid",
		bcid: "bcid",
		vid: "vid",
		msg: "msg",
		ec: "ec",
		it: "it",
		t: "t",
		r: "r",
		url: "url",
		pt: "pt",
		pv: "pv",
		sid: "sid",
		app_id: "app_id",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "msg", value: "msg")))
    XCTAssertTrue(query.contains(.init(name: "ec", value: "ec")))
    XCTAssertTrue(query.contains(.init(name: "it", value: "it")))
    XCTAssertTrue(query.contains(.init(name: "t", value: "t")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "url", value: "url")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testrayLoad()
{
    let pixel = TrackingPixels.Generator.rayLoad(
        pid: "pid",
		bid: "bid",
		bcid: "bcid",
		sid: "sid",
		vid: "vid",
		it: "it",
		pv: "pv",
		pt: "pt",
		r: "r",
		t: "t",
		url: "url",
		lvl: "lvl",
		vvuid: "vvuid",
		app_id: "app_id",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "it", value: "it")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "t", value: "t")))
    XCTAssertTrue(query.contains(.init(name: "url", value: "url")))
    XCTAssertTrue(query.contains(.init(name: "lvl", value: "lvl")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testbufferStart()
{
    let pixel = TrackingPixels.Generator.bufferStart(
        pid: "pid",
		bid: "bid",
		bcid: "bcid",
		sid: "sid",
		vid: "vid",
		it: "it",
		pv: "pv",
		pt: "pt",
		r: "r",
		t: "t",
		url: "url",
		vvuid: "vvuid",
		app_id: "app_id",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "it", value: "it")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "t", value: "t")))
    XCTAssertTrue(query.contains(.init(name: "url", value: "url")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

func testbufferEnd()
{
    let pixel = TrackingPixels.Generator.bufferEnd(
        pid: "pid",
		bid: "bid",
		bcid: "bcid",
		sid: "sid",
		vid: "vid",
		it: "it",
		bt: "bt",
		pv: "pv",
		pt: "pt",
		r: "r",
		t: "t",
		url: "url",
		vvuid: "vvuid",
		app_id: "app_id",
		cb: "cb",
		m_fwsitesection: "m_fwsitesection",
		spaceid: "spaceid"
    )
    guard let query = pixel.queryItems else { XCTFail("`queryItems` is nil!"); return }
    XCTAssertTrue(query.contains(.init(name: "pid", value: "pid")))
    XCTAssertTrue(query.contains(.init(name: "bid", value: "bid")))
    XCTAssertTrue(query.contains(.init(name: "bcid", value: "bcid")))
    XCTAssertTrue(query.contains(.init(name: "sid", value: "sid")))
    XCTAssertTrue(query.contains(.init(name: "vid", value: "vid")))
    XCTAssertTrue(query.contains(.init(name: "it", value: "it")))
    XCTAssertTrue(query.contains(.init(name: "bt", value: "bt")))
    XCTAssertTrue(query.contains(.init(name: "pv", value: "pv")))
    XCTAssertTrue(query.contains(.init(name: "pt", value: "pt")))
    XCTAssertTrue(query.contains(.init(name: "r", value: "r")))
    XCTAssertTrue(query.contains(.init(name: "t", value: "t")))
    XCTAssertTrue(query.contains(.init(name: "url", value: "url")))
    XCTAssertTrue(query.contains(.init(name: "vvuid", value: "vvuid")))
    XCTAssertTrue(query.contains(.init(name: "app_id", value: "app_id")))
    XCTAssertTrue(query.contains(.init(name: "cb", value: "cb")))
    XCTAssertTrue(query.contains(.init(name: "m.fwsitesection", value: "m_fwsitesection")))
    XCTAssertTrue(query.contains(.init(name: "spaceid", value: "spaceid")))
    
}

}
