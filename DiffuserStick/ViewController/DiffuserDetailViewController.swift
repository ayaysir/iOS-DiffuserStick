//
//  DiffuserDetailViewController.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/14.
//

import UIKit
import AppTrackingTransparency
import GoogleMobileAds

class DiffuserDetailViewController: UIViewController {
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var textComments: UITextView!
  @IBOutlet weak var imgPhoto: UIImageView!
  
  @IBOutlet weak var btnDeleteOutlet: UIButton!
  
  @IBOutlet weak var lblFutureChangeDate: UILabel!
  @IBOutlet weak var lblRemainDays: UILabel!
  @IBOutlet weak var lblLastChangedDate: UILabel!
  
  @IBOutlet weak var btnReplaceOutlet: UIButton!
  @IBOutlet weak var btnArchiveOutlet: UIButton!
  @IBOutlet weak var btnEditOutlet: UIButton!
  @IBOutlet weak var btnShare: UIButton!
  @IBOutlet weak var btnTrayUpToList: UIButton!
  
  @IBOutlet weak var innerAdView: UIView!
  var bannerView: GADBannerView!
  
  var selectedDiffuser: DiffuserVO?
  var currentArrayIndex: Int?
  var delegate: DetailViewDelegate?
  var archiveDelegate: ArchiveDetailViewDelegate?
  var isDiffuserModified: Bool = false
  
  // MARK: - Life Cycles
  
  override func viewWillAppear(_ animated: Bool) {
    lblTitle.text = selectedDiffuser?.title
    imgPhoto.image = getImage(fileNameWithExt: selectedDiffuser!.photoName)
    textComments.text = selectedDiffuser!.comments
    displayDates()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 버튼 원형으로 만들기
    let buttons = [btnEditOutlet, btnDeleteOutlet, btnReplaceOutlet, btnArchiveOutlet]
    for button in buttons {
      button?.frame = CGRect(x: 160, y: 100, width: 50, height: 50)
      button?.layer.cornerRadius = 0.5 * (button?.bounds.size.width ?? 10)
      button?.clipsToBounds = true
    }
    
    btnShare.layer.cornerRadius = 0.5 * btnShare.bounds.size.width
    btnTrayUpToList.layer.cornerRadius = 0.5 * btnTrayUpToList.bounds.size.width
    
    // 이미지 탭 이벤트 추가
    imgPhoto.isUserInteractionEnabled = true

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showFullScreenImage))
    imgPhoto.addGestureRecognizer(tapGesture)
        
    // 보관된 글인 경우 안보이게 할 요소들
    if selectedDiffuser?.isFinished == true {
      btnReplaceOutlet.isHidden = true
      btnArchiveOutlet.isHidden = true
      btnEditOutlet.isHidden = true
      lblFutureChangeDate.isHidden = true
      lblRemainDays.isHidden = true
      lblLastChangedDate.isHidden = true
      // btnTrayUpToList.isHidden = false
    } else {
      btnTrayUpToList.isHidden = true
    }
    
    if AdManager.default.isReallyShowAd {
      if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
          // Tracking authorization completed. Start loading ads here
        })
      }
      
      setupBannerView()
    }
  }
  
  override func viewDidLayoutSubviews() {
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    delegate?.replaceModifiedDiffuser(self, diffuser: selectedDiffuser!, isModified: isDiffuserModified, index: currentArrayIndex!)
  }
  
  // MARK: - Actions
  
  @IBAction func btnClose(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func btnModify(_ sender: Any) {
    performSegue(withIdentifier: "modifyView", sender: nil)
  }
  
  @IBAction func btnRefresh(_ sender: Any) {
    let oldDate = selectedDiffuser?.startDate
    let newDate = Date()
    selectedDiffuser?.startDate = newDate
    let updateResult = updateCoreData(id: selectedDiffuser!.id, diffuserVO: selectedDiffuser!)
    
    if updateResult {
      displayDates()
      delegate?.replaceModifiedDiffuser(self, diffuser: selectedDiffuser!, isModified: true, index: currentArrayIndex!)
      simpleAlert(self, message: "디퓨저 교체 날짜를 오늘로 새로고침하였습니다.", title: "교체되었습니다.", handler: nil)
    } else {
      selectedDiffuser?.startDate = oldDate!
      displayDates()
      simpleAlert(self, message: "오류로 인해 날짜가 교체되지 않았습니다.")
    }
  }
  
  @IBAction func btnArchive(_ sender: Any) {
    selectedDiffuser?.isFinished = true
    let updateResult = updateCoreData(id: selectedDiffuser!.id, diffuserVO: selectedDiffuser!)
    if updateResult {
      // 리스트에서 삭제
      simpleAlert(self, message: "보관함으로 이동했습니다. 보관함 메뉴에서 열람할 수 있습니다.", title: "보관함으로 이동") { action in
        self.delegate?.sendArchive(self, diffuser: self.selectedDiffuser!, isModified: true, index: self.currentArrayIndex!)
        self.dismiss(animated: true, completion: nil)
      }
    } else {
      
    }
  }
  
  @IBAction func btnDeleteAct(_ sender: Any) {
    if !selectedDiffuser!.isFinished {
      simpleDestructiveYesAndNo(self, message: "정말 삭제하시겠습니까?", title: "삭제") { action in
        let deleteResult = deleteCoreData(id: self.selectedDiffuser!.id)
        if deleteResult {
          self.delegate?.deleteFromList(self, diffuser: self.selectedDiffuser!, index: self.currentArrayIndex!)
          self.dismiss(animated: true, completion: nil)
        } else {
          simpleAlert(self, message: "삭제에 실패했습니다.")
        }
      }
    } else {
      simpleDestructiveYesAndNo(self, message: "정말 삭제하시겠습니까?", title: "삭제") { action in
        let deleteResult = deleteCoreData(id: self.selectedDiffuser!.id)
        if deleteResult {
          self.archiveDelegate?.deleteFromList(self, diffuser: self.selectedDiffuser!, index: self.currentArrayIndex!)
          self.dismiss(animated: true, completion: nil)
        } else {
          simpleAlert(self, message: "삭제에 실패했습니다.")
        }
      }
    }
  }
  
  @IBAction func btnActShare(_ sender: UIButton) {
    guard let image = imgPhoto.image else {
      print("BtnActShare Error: Image not found")
      return
    }
    
    var shareList = [AnyObject]()
    shareList.append(image)
      
    shareList.append("나의 디퓨저: \(lblTitle.text ?? "") - DiffuserStick App에서 보냄" as NSString)
    let activityVC = UIActivityViewController(activityItems: shareList, applicationActivities: nil)
    activityVC.excludedActivityTypes = [.postToTwitter, .postToWeibo, .postToVimeo, .postToFlickr, .postToFacebook, .postToTencentWeibo]
    activityVC.popoverPresentationController?.sourceView = self.view
    self.present(activityVC, animated: true, completion: nil)
  }
  
  @IBAction func btnActTrayUp(_ sender: UIButton) {
    performSegue(withIdentifier: "rewriteView", sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "modifyView":
      guard let modifyViewController = segue.destination as? DiffuserAddViewController else { return }
      modifyViewController.mode = .modify
      modifyViewController.selectedDiffuser = selectedDiffuser
      modifyViewController.modifyDelegate = self
    case "rewriteView":
      guard let rewriteVC = segue.destination as? DiffuserAddViewController else { return }
      rewriteVC.mode = .rewrite
      rewriteVC.selectedDiffuser = selectedDiffuser
      // rewriteVC.delegate = self
    default:
      break
    }
  }
  
  // MARK: - OBJC Actions
  
  @objc private func showFullScreenImage() {
    guard let image = imgPhoto.image else {
      return
    }
    
    let vc = ImageViewerViewController(image: image)
    vc.modalPresentationStyle = .fullScreen
    present(vc, animated: true)
  }
}

extension DiffuserDetailViewController: UIScrollViewDelegate {
  // MARK: - UIScrollViewDelegate
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imgPhoto
  }
}

extension DiffuserDetailViewController: ModifyDelegate {
  // MARK: - ModifyDelegate
  
  func sendDiffuser(_ controller: DiffuserAddViewController, diffuser: DiffuserVO) {
    // 먼저 detail view의 내용을 갱신하고
    selectedDiffuser = diffuser
    // view model의 vo 도 교체한다.
    isDiffuserModified = true
  }
}

extension DiffuserDetailViewController: AddDelegate {
  // MARK: - RewriteDelegate
  
  
}

extension DiffuserDetailViewController {
  // MARK: - Label Formats
  
  func displayDates() {
    lblLastChangedDate.text = formatLastChanged(date: selectedDiffuser!.startDate)
    lblFutureChangeDate.text = formatFutureChange(date: selectedDiffuser!.startDate, addDay: selectedDiffuser!.usersDays)
    
    // 마지막 교체일과 오늘 날짜와의 차이
    let calendar = Calendar(identifier: .gregorian)
    let betweenDays = selectedDiffuser!.usersDays - calendar.numberOfDaysBetween(selectedDiffuser!.startDate, and: Date())
    
    if betweenDays > 0 {
      lblRemainDays.text = "\(betweenDays)일 후 교체 필요"
    } else {
      lblRemainDays.text = "교체일이 지났습니다. 당장 교체해야 합니다!"
    }
  }
  
  func formatLastChanged(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "마지막 디퓨저 교체일은 YYYY년 M월 dd일 입니다."
    return formatter.string(from: date)
  }

  func formatFutureChange(date: Date, addDay: Int) -> String {
    var dateComponent = DateComponents()
    dateComponent.day = addDay
    
    let futureDate = Calendar.current.date(byAdding: dateComponent, to: date)
    let formatter = DateFormatter()
    formatter.dateFormat = "다음 디퓨저 교체일은 YYYY년 M월 dd일 입니다."
    return formatter.string(from: futureDate!)
  }
}


extension DiffuserDetailViewController: GADBannerViewDelegate {
  // MARK: - Ads
  
  // innerAdView 아웃렛
  func setupBannerView() {
    // 광고
    innerAdView.backgroundColor = nil
    bannerView = GADBannerView(adSize: GADAdSizeBanner)
    addBannerViewToView(bannerView)
    bannerView.adUnitID = Bundle.main.object(forInfoDictionaryKey: "GADDetail") as? String
    bannerView.rootViewController = self
    bannerView.delegate = self
    bannerView.load(GADRequest())
  }
  
  func addBannerViewToView(_ bannerView: GADBannerView) {
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    innerAdView.addSubview(bannerView)
    innerAdView.addConstraints(
      [NSLayoutConstraint(item: bannerView,
                          attribute: .centerX,
                          relatedBy: .equal,
                          toItem: innerAdView,
                          attribute: .centerX,
                          multiplier: 1,
                          constant: 0)
      ])
  }
}
