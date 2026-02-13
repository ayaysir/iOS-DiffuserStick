//
//  MainActiveListViewController.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/13.
//

import UIKit
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

enum CurrentSort {
  case orderByCreateDateDesc
  case orderByRemainDayAsc
  case orderByRemainDayDesc
}

class MainActiveListViewController: UIViewController {
  
  @IBOutlet weak var constraintBottom: NSLayoutConstraint!
  var currentSelectedDiffuser: DiffuserVO? = nil
  var currentArrayIndex: Int = 0
  var currentSort: CurrentSort = .orderByCreateDateDesc
  
  // Local push
  let userNotiCenter = UNUserNotificationCenter.current()
  
  // AdMob
  private var bannerView: GADBannerView!
  
  @IBOutlet weak var naviBar: UINavigationBar!
  @IBOutlet weak var tblList: UITableView!
  @IBOutlet weak var btnSortOutlet: UIBarButtonItem!
  
  // MVVM 2: view Model 클래스의 인스턴스 생성
  let viewModel = DiffuserViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print(getDocumentsDirectory().absoluteString.replacingOccurrences(of: "file://", with: ""))
    
    // Core Data를 view model에 fetch
    do {
      viewModel.diffuserInfoList = try readCoreData()!
    } catch {
      print(error)
    }
    
    requestAuthNoti()
    naviBar.delegate = self
    
    if AdManager.default.isReallyShowAd {
      if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
          // Tracking authorization completed. Start loading ads here
        })
      }
      
      setupBannerView()
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(appClosed), name: UIApplication.willResignActiveNotification, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(appOpened), name: UIApplication.didBecomeActiveNotification, object: nil)
    
    // Receive local noti
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleDiffuserPush),
      name: .didReceiveDiffuserPush,
      object: nil
    )
    
    // Receive rewrite finished
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleTableRefresh),
      name: .didRewriteDiffuserPush,
      object: nil
    )
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if !AdManager.default.isReallyShowAd && bannerView != nil {
      bannerView.removeFromSuperview()
      // constraint 원상복구
      constraintBottom.constant = +50
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // data 목록을 app group 폴더에 작성
    sendDiffusersToWidget()
    
    if #available(iOS 13.0, *) {
      if let diffuserId = SceneDelegate.pendingDiffuserId {
        SceneDelegate.pendingDiffuserId = nil
        guard let index = viewModel.getDiffuserInfoIndex(of: diffuserId) else {
          print("Error: no such diffuserId in viewModel")
          return
        }
        
        showDetailView(at: index)
      }
    }
  }
  
  @objc func appClosed() {
    print("===== app closed =====")
    UserDefaults.standard.setValue(Date(), forKey: "last-closed-date")
  }
  
  @objc func appOpened() {
    print("===== app opened =====")
    tblList.reloadData()
  }
  
  @objc func handleDiffuserPush(_ noti: Notification) {
    guard let diffuserId = noti.userInfo?["diffuserId"] as? UUID else {
      print("Error: no diffuserId in notification")
      return
    }
    
    print("MainActiveVC received diffuserId: \(diffuserId)")
    guard let index = viewModel.getDiffuserInfoIndex(of: diffuserId) else {
      print("Error: no such diffuserId in viewModel")
      return
    }
    
    showDetailView(at: index)
  }
  
  @objc func handleTableRefresh(_ noti: Notification) {
    guard let receivedDiffuser = noti.object as? DiffuserVO else {
      print("Error: no receivedDiffuser in notification")
      return
    }
    
    viewModel.addDiffuserInfo(diffuser: receivedDiffuser)
    tblList.reloadData()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "detailView" {
      guard let detailViewController = segue.destination as? DiffuserDetailViewController else { return }
      detailViewController.selectedDiffuser = currentSelectedDiffuser
      detailViewController.currentArrayIndex = currentArrayIndex
      detailViewController.delegate = self
    } else if segue.identifier == "addView" {
      // 디퓨저 추가(add)
      guard let addViewController = segue.destination as? DiffuserAddViewController else { return }
      addViewController.delegate = self
    }
  }
  
  @IBAction func btnAdd(_ sender: Any) {
    performSegue(withIdentifier: "addView", sender: nil)
  }
  
  @IBAction func btnSort(_ sender: Any) {
    let alertController = UIAlertController(
      title: "loc.main.sort.title".localized,
      message: "loc.main.sort.message".localized,
      preferredStyle: .actionSheet
    )
    
    let sortDefault = UIAlertAction(
      title: "loc.main.sort.action.default".localized,
      style: .default
    ) { action in
      if self.currentSort == .orderByCreateDateDesc { return }
      self.viewModel.sortByCreateDateDesc()
      self.tblList.reloadData()
      self.tblList.setContentOffset(.zero, animated: true)
      self.currentSort = .orderByCreateDateDesc
    }
    
    let sortReplaceAsc = UIAlertAction(
      title: "loc.main.sort.action.replace.asc".localized,
      style: .default
    ) { action in
      if self.currentSort == .orderByRemainDayAsc { return }
      self.viewModel.sortByStartDateAsc()
      self.tblList.reloadData()
      self.tblList.setContentOffset(.zero, animated: true)
      self.currentSort = .orderByRemainDayAsc
    }
    
    let sortReplaceDsc = UIAlertAction(
      title: "loc.main.sort.action.replace.dsc".localized,
      style: .default
    ) { action in
      if self.currentSort == .orderByRemainDayDesc { return }
      self.viewModel.sortByStartDateDesc()
      self.tblList.reloadData()
      self.tblList.setContentOffset(.zero, animated: true)
      self.currentSort = .orderByRemainDayDesc
    }
    
    alertController.addAction(sortDefault)
    alertController.addAction(sortReplaceAsc)
    alertController.addAction(sortReplaceDsc)
    self.present(alertController, animated: true, completion: nil)
  }
  
  //  Local push
  // 사용자에게 알림 권한 요청
  func requestAuthNoti() {
    let notiAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
    userNotiCenter.requestAuthorization(options: notiAuthOptions) { (success, error) in
      if let error = error {
        print(#function, error)
      }
    }
  }
  
  /// 디퓨저 상세 페이지로 이동
  func showDetailView(at indexPathRow: Int) {
    currentSelectedDiffuser = viewModel.getDiffuserInfo(at: indexPathRow)
    currentArrayIndex = indexPathRow
    performSegue(withIdentifier: "detailView", sender: nil)
  }
  
  func sendDiffusersToWidget() {
    let dtos = viewModel.diffuserInfoList.map {
      DiffuserWidgetDTO(
        id: $0.id,
        title: $0.title,
        lastStartDate: $0.startDate,
        usersDays: $0.usersDays
      )
    }
    saveDiffusersToAppGroup(diffuserWidgetDTOs: dtos)
    
    // 이미지를 위젯으로 보내기
    viewModel.diffuserInfoList.forEach { diffuser in
      guard let image = getImage(fileNameWithExt: diffuser.photoName) else {
        return
      }
      guard let thumb = makeImageThumbnail(image: image, maxPixelSize: 200) else {
        return
      }
      _ = saveImage(
        thumb,
        fileName: diffuser.id.uuidString,
        location: .appGroup(identifier: .shdAppGroupIdentifier, subdirectory: "thumbs")
      )
    }
  }
}

extension MainActiveListViewController: UITableViewDelegate, UITableViewDataSource {
  // MVVM 3: 뷰모델 인스턴스에서 갯수 가져오기
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if viewModel.numOfDiffuserInfoList == 0 {
      tableView.displayBackgroundMessage("loc.main.empty.list".localized)
    } else {
      tableView.dismissBackgroundMessage()
    }
    return viewModel.numOfDiffuserInfoList
  }
  
  // MVVM 4: 뷰모델 인스턴스에 VO 가져오고 커스템 셀에 정보 업데이트
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DiffuserListCell else {
      return UITableViewCell()
    }
    
    let diffuserInfo = viewModel.getDiffuserInfo(at: indexPath.row)
    cell.update(info: diffuserInfo)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // currentSelectedDiffuser = viewModel.getDiffuserInfo(at: indexPath.row)
    // currentArrayIndex = indexPath.row
    // performSegue(withIdentifier: "detailView", sender: nil)
    showDetailView(at: indexPath.row)
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let deleteAction = UITableViewRowAction(style: .destructive, title: "loc.common.delete".localized) { (_, index) in
      simpleDestructiveYesAndNo(
        self,
        message: "loc.alert.delete.message".localized,
        title: "loc.common.delete".localized
      ) { action in
        let deleteResult = deleteCoreData(id: self.viewModel.diffuserInfoList[indexPath.row].id)
        if deleteResult {
          self.viewModel.diffuserInfoList.remove(at: (indexPath as NSIndexPath).row)
          tableView.deleteRows(at: [indexPath], with: .fade)
        }
      }
    }
    
    let refreshAction = UITableViewRowAction(style: .normal, title: "loc.common.replace".localized) { [unowned self] (_, _) in
      var diffuserInfo = viewModel.diffuserInfoList[indexPath.row]
      let newDate = Date()
      diffuserInfo.startDate = newDate
      
      let updateResult = updateCoreData(id: diffuserInfo.id, diffuserVO: diffuserInfo)
      
      if updateResult {
        viewModel.diffuserInfoList[indexPath.row] = diffuserInfo
        simpleAlert(
          self,
          message: "loc.alert.replace.complete.message".localized,
          title: "loc.alert.replace.complete.title".localized
        ) { [unowned self] _ in
          tblList.reloadData()
        }
      } else {
        simpleAlert(self, message: "loc.alert.replace.error.message".localized)
      }
    }
    refreshAction.backgroundColor = .systemGreen
    
    // 배열에서 나중에 있는 것이 제일 왼쪽으로 온다
    return [deleteAction, refreshAction,]
  }
}

class DiffuserListCell: UITableViewCell {
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblRemainDayText: UILabel!
  @IBOutlet weak var lblExpirationDate: UILabel!
  @IBOutlet weak var thumbnailView: UIImageView!
  
  // 리프레시 테스트 전용 (배포판에선 안보여야 함)
  @IBOutlet weak var lblRefreshTest: UILabel!
  
  // 커스텀 셀의 데이터 업데이트
  func update(info: DiffuserVO) {
    // 마지막 교체일과 오늘 날짜와의 차이
    // let calendar = Calendar(identifier: .gregorian)
    // let betweenDays = info.usersDays - calendar.numberOfDaysBetween(info.startDate, and: Date())
    let betweenDays = info.startDate.diffuserDaysRemaining(totalDays: info.usersDays)
    lblTitle.text = info.title
    
    if betweenDays > 3 {
      lblRemainDayText.text = "loc.common.need.replace".localizedFormat(betweenDays)
      self.contentView.backgroundColor = nil
    } else if betweenDays <= 3 && betweenDays > 0 {
      lblRemainDayText.text = "loc.common.need.replace".localizedFormat(betweenDays)
      // self.contentView.backgroundColor = #colorLiteral(red: 0.9773717523, green: 0.9611932635, blue: 0.7925902009, alpha: 1)
      contentView.backgroundColor = .cellHighlightYellow
    } else {
      lblRemainDayText.text = "loc.common.need.replace.now".localized
      // self.contentView.backgroundColor = #colorLiteral(red: 0.9926608205, green: 0.8840166926, blue: 0.8681346178, alpha: 1)
      contentView.backgroundColor = .cellHighlightRed
    }
    
    // 마지막 교체일 또는 신규 등록일에 따라 레이블 구분 (교체, 설치? 등록?)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "loc.common.date.formatted.formal".localized
    let dateString = dateFormatter.string(from: info.startDate)
    // lblExpirationDate.text = "\(dateString)에 교체됨"
    lblExpirationDate.text = "loc.common.date.replaced".localizedFormat(dateString)
    thumbnailView.image = getImage(fileNameWithExt: info.photoName)
    thumbnailView.layer.cornerRadius = 8
    thumbnailView?.clipsToBounds = true
    
    // 리프레시 테스트 전용 (배포판에선 안보여야 함)
    let numRange = 1...100
    lblRefreshTest.text = String(Int.random(in: numRange))
    
  }
}

// MVVM 1: 뷰 모델 클래스 생성
class DiffuserViewModel {
  
  var diffuserInfoList: [DiffuserVO] = [
    DiffuserVO(title: "제 2회의실 탁자에 있는 엘레강스 디퓨저", startDate: Date(timeIntervalSince1970: 1625065200), comments: "", usersDays: 30, photoName: "", id: UUID(), createDate: Date(), isFinished: false),
    DiffuserVO(title: "제 2회의실 TV 밑 선반에 있는 체리시 향의 디퓨저", startDate: Date(timeIntervalSince1970: 1623733399), comments: "", usersDays: 30, photoName: "", id: UUID(), createDate: Date(), isFinished: false),
    DiffuserVO(title: "로비 위에 있는 섬유향 디퓨저", startDate: Date(timeIntervalSince1970: 1626066199), comments: "", usersDays: 30, photoName: "", id: UUID(), createDate: Date(), isFinished: false),
    DiffuserVO(title: "복사기 옆에 있는 르네상스 디퓨저", startDate: Date(), comments: "", usersDays: 30, photoName: "", id: UUID(), createDate: Date(), isFinished: false),
  ]
  
  var numOfDiffuserInfoList: Int {
    return diffuserInfoList.count
  }
  
  func getDiffuserInfo(at index: Int) -> DiffuserVO {
    return diffuserInfoList[index]
  }
  
  func getDiffuserInfoIndex(of id: UUID) -> Int? {
    return diffuserInfoList.firstIndex(where: { $0.id == id })
  }
  
  func addDiffuserInfo(diffuser: DiffuserVO) {
    diffuserInfoList.insert(diffuser, at: 0)
  }
  
  // test - 나중에 삭제
  func printViewModel() {
    print(diffuserInfoList)
  }
  
  func sortByStartDateDesc() {
    diffuserInfoList = diffuserInfoList.sorted { lhs, rhs in
      let remainDay1 = lhs.startDate.diffuserDaysRemaining(totalDays: lhs.usersDays)
      let remainDay2 = rhs.startDate.diffuserDaysRemaining(totalDays: rhs.usersDays)
      return remainDay1 > remainDay2
    }
  }
  
  func sortByStartDateAsc() {
    diffuserInfoList = diffuserInfoList.sorted { lhs, rhs in
      let remainDay1 = lhs.startDate.diffuserDaysRemaining(totalDays: lhs.usersDays)
      let remainDay2 = rhs.startDate.diffuserDaysRemaining(totalDays: rhs.usersDays)
      return remainDay1 < remainDay2
    }
  }
  
  func sortByCreateDateDesc() {
    diffuserInfoList = diffuserInfoList.sorted { obj1, obj2 in
      let createDay1 = obj1.createDate
      let createDay2 = obj2.createDate
      return createDay1 > createDay2
    }
  }
  
}

extension MainActiveListViewController: AddDelegate {
  // AddDelegate
  func sendDiffuser(_ controller: DiffuserAddViewController, diffuser: DiffuserVO) {
    viewModel.addDiffuserInfo(diffuser: diffuser)
    tblList.reloadData()
    sendDiffusersToWidget()
  }
  
}

extension MainActiveListViewController: DetailViewDelegate {
  func deleteFromList(_ controller: DiffuserDetailViewController, diffuser: DiffuserVO, index: Int) {
    self.viewModel.diffuserInfoList.remove(at: index)
    tblList.reloadData()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      simpleAlert(
        self,
        message: "loc.alert.delete.complete.message".localized,
        title: "loc.alert.delete.complete.title".localized,
        handler: nil
      )
    }
    sendDiffusersToWidget()
  }
  
  func sendArchive(_ controller: DiffuserDetailViewController, diffuser: DiffuserVO, isModified: Bool, index: Int) {
    if isModified {
      viewModel.diffuserInfoList.remove(at: index)
      tblList.reloadData()
      SendToArchive.sharedInstance.isNeedReloadCDData = true
      sendDiffusersToWidget()
    }
  }
  
  func replaceModifiedDiffuser(_ controller: DiffuserDetailViewController, diffuser: DiffuserVO, isModified: Bool, index: Int) {
    if isModified {
      // TODO: - 2024-2-28: 보관함으로 이동시 IndexOfRange 에러 발생했는데 정확한 조건을 알 수 없음
      viewModel.diffuserInfoList[index] = diffuser
      tblList.reloadData()
      sendDiffusersToWidget()
    }
  }
}

// 노치 채우기
extension MainActiveListViewController: UINavigationBarDelegate {
  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
}

// ============ 애드몹 셋업 ============
extension MainActiveListViewController: GADBannerViewDelegate {
  /*
   본 클래스에 다음 선언 추가:
   // AdMob
   private var bannerView: GADBannerView!
   
   viewDidLoad()에 다음 추가:
   setupBannerView()
   */
  
  private func setupBannerView() {
    let adSize = GADAdSizeFromCGSize(CGSize(width: self.view.frame.width, height: 50))
    self.bannerView = GADBannerView(adSize: adSize)
    addBannerViewToView(bannerView)
    // bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // test
    bannerView.adUnitID = Bundle.main.object(forInfoDictionaryKey: "GADHome") as? String
    print("adUnitID: ", bannerView.adUnitID!)
    bannerView.rootViewController = self
    bannerView.load(GADRequest())
    bannerView.delegate = self
    // tblList의 align bottom to 를 50만큼 올린다.
    constraintBottom.constant = -50
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
    print("GAD: \(#function)", error)
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
