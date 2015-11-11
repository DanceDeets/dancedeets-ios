//
//  WebViewController.swift
//  DanceDeets
//
//  Created by LambertMike on 2015/11/10.
//  Copyright © 2015年 david.xiang. All rights reserved.
//

import Foundation
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var url: NSURL?

    func setStartUrl(startUrl: String) {
        url = NSURL(string: startUrl)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(false, animated: false)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }

    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if url != nil {
            // Append &webview=1 to our URLs
            let modUrl = NSURLComponents(URL: url!, resolvingAgainstBaseURL: false)!
            modUrl.queryItems!.append(NSURLQueryItem(name: "webview", value: "1"))
            if let newUrl = modUrl.URL {
                webView.loadRequest(NSURLRequest(URL: newUrl))
            }
        }
        // TODO: If we want to use http, we probably need to disable app transport security
        // TODO: set up a navigation controller, that lets us go back?
    }


    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        let isFrame = navigationAction.request.URL?.absoluteString != navigationAction.request.mainDocumentURL?.absoluteString
        if isFrame {
            decisionHandler(WKNavigationActionPolicy.Allow)
            return
        }

        if let destUrl = navigationAction.request.URL {
            if destUrl.host == "www.dancedeets.com" {
                decisionHandler(WKNavigationActionPolicy.Allow)
                return
            }
            UIApplication.sharedApplication().openURL(destUrl);
            decisionHandler(WKNavigationActionPolicy.Cancel)
        }
    }
}
