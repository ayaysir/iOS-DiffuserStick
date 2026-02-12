//
//  SettingTableViewController.swift
//  DiffuserStick
//
//  Created by 윤범태 on 2/29/24.
//

import UIKit
import MessageUI
import StoreKit
import AppTrackingTransparency
import GoogleMobileAds

class SettingTableViewController: UITableViewController {
  private let SECTION_IAP = 0
  private let SECTION_DAYS = 1
  private let SECTION_HELP = 2
  private let SECTION_OTHER = 3
  private let SECTION_AD_CONTAINER = 4
  
  private var bannerView: GADBannerView!
  private var iapProducts: [SKProduct]?
  
  @IBOutlet weak var lblDays: UILabel!
  @IBOutlet weak var stepperDaysOutlet: UIStepper!
  
  @IBOutlet weak var lblRestoreIAP: UILabel!
  @IBOutlet weak var lblShowHelp: UILabel!
  @IBOutlet weak var lblSendEmailToDev: UILabel!
  @IBOutlet weak var lblAppTour: UILabel!
  
  private var currentDays = UserDefaults.standard.integer(forKey: "config-defaultDays")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initDays()
    initIAP()
    
    // Localizable texts
    self.title = "설정 및 더보기"
    lblRestoreIAP.text = "구입 정보 복원"
    lblShowHelp.text = "도움말 보기"
    lblSendEmailToDev.text = "개발자에게 메일 보내기"
    lblAppTour.text = "개발자의 다른 앱 둘러보기"
    
    
    if AdManager.default.isReallyShowAd {
      if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
          // Tracking authorization completed. Start loading ads here
        })
      }
      
      setupBannerView()
    }
  }
  
  @IBAction func stepperActChangeDays(_ sender: UIStepper) {
    let days = Int(sender.value)
    lblDays.text = String(days) + "일"
    refreshDefaultDaysOfConfig(days)
  }
}

extension SettingTableViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
    case SECTION_IAP:
      if let iapProducts, indexPath.row < iapProducts.count {
        let product = iapProducts[indexPath.row]
        purchaseIAP(productID: product.productIdentifier)
      } else {
        restoreIAP()
      }
    case SECTION_OTHER:
      if indexPath.row == 0 {
        launchEmail()
      } else if indexPath.row == 1 {
        let vc = AppExhibitionTableViewController()
        navigationController?.pushViewController(vc, animated: true)
      }
    default:
      break
    }
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case SECTION_AD_CONTAINER:
      return "현재 앱 버전: \(AppMetadataUtil.appVersionAndBuild())"
    case SECTION_IAP:
      return "인 앱 결제"
    case SECTION_DAYS:
      return "기본 설정 기간"
    case SECTION_HELP:
      return "도움말"
    case SECTION_OTHER:
      return "기타"
    default:
      break
    }
    
    return super.tableView(tableView, titleForHeaderInSection: section)
  }
  
  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    switch section {
    case SECTION_IAP:
      return "앱 내 구입을 통해 앱 내의 모든 광고를 제거할 수 있습니다. 더 나은 앱과 서비스를 제공할 수 있도록 응원해 주시면 감사하겠습니다."
    case SECTION_DAYS:
      return "교체 일수를 입력하세요. 디퓨저 스틱의 일반적인 권장 교체기간은 30일입니다."
    default:
      break
    }
    
    return super.tableView(tableView, titleForFooterInSection: section)
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if section == SECTION_AD_CONTAINER && Bundle.main.object(forInfoDictionaryKey: "ShowAd") as! Bool {
      return 50
    }
    
    return super.tableView(tableView, heightForFooterInSection: section)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == SECTION_IAP {
      return (iapProducts?.count ?? 0) + 1
    }
    
    return super.tableView(tableView, numberOfRowsInSection: section)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // TODO: - 상품 표시 부분 바뀐 내용 적용하기 ->
    // 구입 완료시 변경 내용 반영되게
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    
    if let iapProducts, indexPath.section == SECTION_IAP,
       indexPath.row < iapProducts.count {
      let currentProduct = iapProducts[indexPath.row]
      let isPurchased = InAppProducts.helper.isProductPurchased(currentProduct.productIdentifier)
      
      // 상품 정보 레이블 셀
      if let firstLabel = cell.contentView.subviews[0] as? UILabel {
        firstLabel.text = iapProducts[indexPath.row].localizedTitle
        
        if let localizedPrice = iapProducts[indexPath.row].localizedPrice {
          firstLabel.text! += " (\(localizedPrice))"
        }
        
        firstLabel.textColor = isPurchased ? .lightGray : nil
      }
      
      if let secondLabel = cell.contentView.subviews[1] as? UILabel {
        secondLabel.text = isPurchased ? "[구입 완료]" : "[미구입]"
        secondLabel.textColor = isPurchased ? .systemGreen : .darkGray
      }
    }
    
    return cell
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
    
    lblDays.text = String(currentDays) + "일"
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

/*
 ===> 인앱 결제로 광고 제거
 */
extension SettingTableViewController {
  private func initIAP() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleIAPPurchase(_:)), name: .IAPHelperPurchaseNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(hadnleIAPError(_:)), name: .IAPHelperErrorNotification, object: nil)
    
    // IAP 불러오기
    InAppProducts.helper.inquireProductsRequest { [weak self] (success, products) in
      guard let self, success else { return }
      self.iapProducts = products
      
      DispatchQueue.main.async { [weak self] in
        guard let self,
              let products else {
          return
        }
        
        // 불러오기 후 할 UI 작업
        tableView.reloadSections([SECTION_IAP], with: .none)
        
        products.forEach {
          if !InAppProducts.helper.isProductPurchased($0.productIdentifier) {
            print("\($0.localizedTitle) (\($0.price))")
          }
        }
      }
    }
    
    if InAppProducts.helper.isProductPurchased(InAppProducts.productIDs[0]) || UserDefaults.standard.bool(forKey: InAppProducts.productIDs[0]) {
      // changePurchaseButtonStyle(isPurchased: true)
    }
  }
  
  /// 구매: 인앱 결제 버튼 눌렀을 때
  private func purchaseIAP(productID: String) {
    if let product = iapProducts?.first(where: {productID == $0.productIdentifier}),
       !InAppProducts.helper.isProductPurchased(productID) {
      InAppProducts.helper.buyProduct(product)
      LoadingIndicatorUtil.default.show(
        self,
        style: .blur,
        text: "결제 작업을 처리중입니다.\n잠시만 기다려 주세요...")
    } else {
      simpleAlert(self, message: "구매 완료되었습니다. 이제 앱에서 광고가 표시되지 않습니다.", title: "구매 완료", handler: nil)
    }
  }
  
  /// 복원: 인앱 복원 버튼 눌렀을 때
  private func restoreIAP() {
    InAppProducts.helper.restorePurchases()
  }
  
  /// 결제 후 Notification을 받아 처리
  @objc func handleIAPPurchase(_ notification: Notification) {
    guard notification.object is String else {
      simpleAlert(self, message: "구매 실패: 다시 시도해주세요.")
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      simpleAlert(self, message: "구매 완료되었습니다. 이제 앱에서 광고가 표시되지 않습니다.", title: "구매 완료") { [weak self] action in
        guard let self else { return }
        // 결제 성공하면 해야할 작업...
        // 1. 로딩 인디케이터 숨기기
        LoadingIndicatorUtil.default.hide(self)
        
        // 2. 세팅VC 광고 제거 (나머지 뷰는 다시 들어가면 제거되어 있음)
        bannerView.removeFromSuperview()
        
        // 3. 버튼
        tableView.reloadData()
      }
    }
  }
  
  @objc func hadnleIAPError(_ notification: Notification) {
    LoadingIndicatorUtil.default.hide(self)
  }
  
  // private func changePurchaseButtonStyle(isPurchased: Bool, buttonTitleForSell: String? = nil) {
  //     let buttonTitle = isPurchased ? "구매 완료".localized : buttonTitleForSell
  //     btnPurchaseAdRemoval.backgroundColor = isPurchased ? .green : .button
  //     btnPurchaseAdRemoval.setTitle(buttonTitle, for: .normal)
  //     btnPurchaseAdRemoval.isEnabled = true
  // }
}

