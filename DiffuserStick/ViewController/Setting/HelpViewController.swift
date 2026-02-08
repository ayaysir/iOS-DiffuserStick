//
//  HelpViewController.swift
//  DiffuserStick
//
//  Created by 윤범태 on 2/29/24.
//

import UIKit
import AppTrackingTransparency
import GoogleMobileAds

@preconcurrency import WebKit

class HelpViewController: UIViewController {
  private var bannerView: GADBannerView!
  @IBOutlet weak var webView: WKWebView!
  @IBOutlet weak var cnstWebViewBottom: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initWebPageLoad()
    
    if AdManager.default.isReallyShowAd {
      if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
          // Tracking authorization completed. Start loading ads here
        })
      }
      
      setupBannerView()
    }
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

// ============ 애드몹 셋업 ============
extension HelpViewController: GADBannerViewDelegate {
  // 본 클래스에 다음 선언 추가
  // // AdMob
  // private var bannerView: GADBannerView!
  
  // viewDidLoad()에 다음 추가
  // setupBannerView()
  
  private func setupBannerView() {
    let adSize = GADAdSizeFromCGSize(CGSize(width: self.view.frame.width, height: 50))
    bannerView = GADBannerView(adSize: adSize)
    addBannerViewToView(bannerView)
    bannerView.adUnitID = Bundle.main.object(forInfoDictionaryKey: "GADSetting") as? String
    bannerView.rootViewController = self
    bannerView.load(GADRequest())
    bannerView.delegate = self
    cnstWebViewBottom.constant -= adSize.size.height
  }
  
  private func addBannerViewToView(_ bannerView: GADBannerView) {
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bannerView)
    view.addConstraints( [NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0), NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0) ])
  }
  
  // GADBannerViewDelegate
  func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
    print("GAD: \(#function)")
  }
  
  func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
    print("GAD: \(#function)")
  }
  
  func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
    print("GAD: \(#function)")
  }
  
  func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
    print("GAD: \(#function)")
  }
  
  func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
    print("GAD: \(#function)")
  }
}
