//
//  SettingTableViewController.swift
//  DiffuserStick
//
//  Created by 윤범태 on 2/29/24.
//

import UIKit
import MessageUI
import GoogleMobileAds

class SettingTableViewController: UITableViewController {
    private let SECTION_IAP = 2
    private let SECTION_OTHER = 3
    private let SECTION_AD_CONTAINER = 4
    
    private var bannerView: GADBannerView!
    
    @IBOutlet weak var lblDays: UILabel!
    @IBOutlet weak var stepperDaysOutlet: UIStepper!
    
    private var currentDays = UserDefaults.standard.integer(forKey: "config-defaultDays")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDays()
        
        if Bundle.main.object(forInfoDictionaryKey: "ShowAd") as! Bool {
            setupBannerView()
        }
    }
    
    @IBAction func stepperActChangeDays(_ sender: UIStepper) {
        let days = Int(sender.value)
        lblDays.text = String(days)
        refreshDefaultDaysOfConfig(days)
    }
}

extension SettingTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case .init(row: 0, section: SECTION_OTHER):
            launchEmail()
        case .init(row: 1, section: SECTION_OTHER):
            let vc = AppExhibitionTableViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_AD_CONTAINER {
            return "현재 앱 버전: \(AppMetadataUtil.appVersionAndBuild())"
        }
        
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == SECTION_AD_CONTAINER && Bundle.main.object(forInfoDictionaryKey: "ShowAd") as! Bool {
            return 50
        }
        
        return super.tableView(tableView, heightForFooterInSection: section)
    }
    
}

extension SettingTableViewController {
    private func initDays() {
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
    }
    
    private func refreshDefaultDaysOfConfig(_ day: Int) {
        UserDefaults.standard.setValue(day, forKey: "config-defaultDays")
    }
}

extension SettingTableViewController: MFMailComposeViewControllerDelegate {
    func launchEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            simpleAlert(self, message: "사용자의 메일 계정이 설정되어 있지 않습니다.", title: "메일 전송 불가", handler: nil)
            return
        }
        
        let emailTitle = "디퓨저 스틱 피드백"
        let messageBody = 
        """
        '디퓨저 스틱'에 대한 문의사항 또는 피드백이 있으신가요?
        
        OS Version: \(AppMetadataUtil.osInfo())
        App Version: \(AppMetadataUtil.appVersionAndBuild())
        Device Name: \(UIDevice.modelName)
        """
        let toRecipents = ["yoonbumtae@gmail.com"]
        
        let mc = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        
        self.present(mc, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            switch result {
            case .cancelled:
                print("Mail cancelled")
            case .saved:
                print("Mail saved")
            case .sent:
                print("Mail sent")
            case .failed:
                if let error {
                    print("Mail sent failure: \(error.localizedDescription)")
                } else {
                    print("Mail sent failure: unknown error")
                }
            default:
                break
            }
        
            self.dismiss(animated: true, completion: nil)
    }
}

// ============ 애드몹 셋업 ============
extension SettingTableViewController: GADBannerViewDelegate {
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
