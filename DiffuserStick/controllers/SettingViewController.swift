//
//  SettingViewController.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/15.
//

import UIKit
import MessageUI
import WebKit
import GoogleMobileAds

func refreshDefaultDaysOfConfig(_ num: Int) {
    UserDefaults.standard.setValue(num, forKey: "config-defaultDays")
}

class SettingViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var stepperDaysOutlet: UIStepper!
    @IBOutlet weak var lblDays: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    // AdMob
    private var bannerView: GADBannerView!
    
    // 폰트 리스트의 이름들 저장 배열
    var availableFontList = [String]()
    
    var currentDays = UserDefaults.standard.integer(forKey: "config-defaultDays")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBannerView()
        
        lblDays.text = String(Int(stepperDaysOutlet.value))
        // 일수 세팅
        if currentDays >= 15 {
            stepperDaysOutlet.value = Double(currentDays)
        } else {
            // 초기화
            stepperDaysOutlet.value = 30.0
            currentDays = 30
            refreshDefaultDaysOfConfig(30)
        }
        lblDays.text = String(currentDays)
        
        // 웹 파일 로딩
        webView.uiDelegate = self
        webView.navigationDelegate = self

        let url = Bundle.main.url(forResource: "help", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    @IBAction func stepperDays(_ sender: Any) {
        let days = Int(stepperDaysOutlet.value)
        lblDays.text = String(days)
        refreshDefaultDaysOfConfig(days)
    }
    
}

extension SettingViewController: MFMailComposeViewControllerDelegate {
    @IBAction func launchEmail(sender: AnyObject) {
        
        guard MFMailComposeViewController.canSendMail() else {
            simpleAlert(self, message: "사용자의 메일 계정이 설정되어 있지 않습니다.", title: "메일 전송 불가", handler: nil)
            return
        }
        
        let emailTitle = "디퓨저 스틱 피드백"
        let messageBody = "'디퓨저 스틱'에 대한 질문 또는 피드백이 있으신가요?"
        let toRecipents = ["friend@stackoverflow.com"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        
        self.present(mc, animated: true, completion: nil)
    }
    
//    private func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
//        switch result {
//        case .cancelled:
//            print("Mail cancelled")
//        case .saved:
//            print("Mail saved")
//        case .sent:
//            print("Mail sent")
//        case .failed:
//            print("Mail sent failure: \(error.localizedDescription)")
//        default:
//            break
//        }
//        self.dismiss(animated: true, completion: nil)
//    }
    
    @objc(mailComposeController:didFinishWithResult:error:)
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,error: Error?) {
            controller.dismiss(animated: true)
        }
    
}

// ============ 애드몹 셋업 ============
extension SettingViewController: GADBannerViewDelegate {
    // 본 클래스에 다음 선언 추가
    // // AdMob
    // private var bannerView: GADBannerView!
    
    // viewDidLoad()에 다음 추가
    // setupBannerView()
    
    private func setupBannerView() {
        let adSize = GADAdSizeFromCGSize(CGSize(width: self.view.frame.width, height: 50))
        bannerView = GADBannerView(adSize: adSize)
//        bannerView.backgroundColor = UIColor(named: "notissuWhite1000s")!
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // test
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
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
