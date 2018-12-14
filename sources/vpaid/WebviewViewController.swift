//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
#if os(iOS)
import Foundation
import WebKit
import CoreMedia
import PlayerCore

typealias VPAIDDispatch = (PlayerCore.VPAIDEvents) -> ()

final class WebviewViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    private var webview: WKWebView? {
        return view as? WKWebView
    }
    
    var dispatch: VPAIDDispatch?
    
    var props: VPAIDProps? {
        didSet {
            guard let props = props else { webview?.stopLoading(); return  }
            guard webview?.isLoading == false else { return }
            evaluateJavaScript(with: props.playbackProps)
        }
    }
    
    init(props: VPAIDProps) {
        self.props = props
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard navigationAction.request.url != webview?.url  else { return nil }
        guard let url = navigationAction.request.url else { return nil }
        dispatch?(.AdWindowOpen(url))
        return nil
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let props = props else { return }
        evaluateJavaScript(with: props.playbackProps)
    }
    
    private func evaluateJavaScript(with props: VPAIDProps.PlaybackProps) {
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(props) else { return }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        webview?.evaluateJavaScript("vpaid_runner.render(\(jsonString))") { [weak self] (object, error) in
            guard let error = error else { return }
            self?.dispatch?(.AdJSEvaluationFailed(error))
        }
    }
    
    override func loadView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.allowsAirPlayForMediaPlayback = false
        config.allowsPictureInPictureMediaPlayback = false
        
        let userController = WKUserContentController()
        userController.add(VPAIDMessageHandler(dispatch: { [weak self] event in
            self?.dispatch?(event)
        }), name: "observer")
        config.userContentController = userController
        
        let webview = WKWebView(frame: .zero, configuration: config)
        webview.backgroundColor = .black
        webview.scrollView.backgroundColor = .black
        webview.scrollView.isScrollEnabled = false
        webview.scrollView.bounces = false
        webview.uiDelegate = self
        webview.navigationDelegate = self
        defer { view = webview }
        
        guard let url = props?.documentUrl,
              let html = try? String(contentsOf: url) else { return }
        webview.loadHTMLString(html, baseURL: url)
    }
}

#endif
