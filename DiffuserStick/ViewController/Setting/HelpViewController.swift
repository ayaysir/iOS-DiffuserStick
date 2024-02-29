//
//  HelpViewController.swift
//  DiffuserStick
//
//  Created by 윤범태 on 2/29/24.
//

import UIKit
import WebKit

class HelpViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initWebPageLoad()
    }
    
    private func initWebPageLoad() {
        // 웹 파일 로딩
        webView.navigationDelegate = self

        let url = Bundle.main.url(forResource: "help", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension HelpViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            return
        }
        
        let appUrl = Bundle.main.resourceURL!
        let targetUrl = appUrl.appendingPathComponent("help.html")
        
        if url.description.lowercased().starts(with: "https://") || url.description.lowercased().starts(with: "http://") {
            UIApplication.shared.open(url)
        }
        
        decisionHandler(targetUrl == url ? .allow : .cancel)
    }
}
