//
//  CurrentViewController.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/13.
//

import UIKit
import GoogleMobileAds

enum CurrentSort {
    case orderByCreateDateDesc
    case orderByRemainDayAsc
    case orderByRemainDayDesc
}

class CurrentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddDelegate {
    
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
    
    // MVVM 3: 뷰모델 인스턴스에서 갯수 가져오기
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        currentSelectedDiffuser = viewModel.getDiffuserInfo(at: indexPath.row)
        currentArrayIndex = indexPath.row
        performSegue(withIdentifier: "detailView", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //        let archiveAction = UITableViewRowAction(style: .normal, title: "Archive") { _, index in
        //            print("archavie")
        //        }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "삭제") { _, index in
            simpleDestructiveYesAndNo(self, message: "정말 삭제하시겠습니까?", title: "삭제") { action in
                let deleteResult = deleteCoreData(id: self.viewModel.diffuserInfoList[indexPath.row].id)
                if deleteResult {
                    self.viewModel.diffuserInfoList.remove(at: (indexPath as NSIndexPath).row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
        return [deleteAction]
    }
    
    //    // 왼쪽 슬라이드 삭제 버튼
    //    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //        if editingStyle == .delete {
    //
    //
    //        } else if editingStyle == .insert {
    //            print("e)dsa")
    //        }
    //    }
    
    
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
        self.setupBannerView()
        
//        tblList.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tableTouched)))
    }
    
    @objc func tableTouched() {
//         view.endEditing(true)
          //textField.resignFirstResponder()  /* This line also worked fine for me */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
   
        let alertController = UIAlertController(title: "정렬", message: "정렬 방식을 선택하세요.", preferredStyle: .alert)
        let sortRegister = UIAlertAction(title: "디퓨저를 등록한 최근 날짜 순서 (기본)", style: .default) { action in
            if self.currentSort == .orderByCreateDateDesc { return }
            self.viewModel.sortByCreateDateDesc()
            self.tblList.reloadData()
            self.tblList.setContentOffset(.zero, animated: true)
            self.currentSort = .orderByCreateDateDesc
        }
        let sortDefault = UIAlertAction(title: "교체일이 가까운 순서", style: .default) { action in
            if self.currentSort == .orderByRemainDayAsc { return }
            self.viewModel.sortByStartDateAsc()
            self.tblList.reloadData()
            self.tblList.setContentOffset(.zero, animated: true)
            self.currentSort = .orderByRemainDayAsc
        }
        let sortReverse = UIAlertAction(title: "교체일이 먼 순서", style: .default) { action in
            if self.currentSort == .orderByRemainDayDesc { return }
            self.viewModel.sortByStartDateDesc()
            self.tblList.reloadData()
            self.tblList.setContentOffset(.zero, animated: true)
            self.currentSort = .orderByRemainDayDesc
        }
        

        
        alertController.addAction(sortRegister)
        alertController.addAction(sortDefault)
        alertController.addAction(sortReverse)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // AddDelegate
    func sendDiffuser(_ controller: DiffuserAddViewController, diffuser: DiffuserVO) {
        viewModel.addDiffuserInfo(diffuser: diffuser)
        tblList.reloadData()
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
    
    
    
}

class DiffuserListCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblRemainDayText: UILabel!
    @IBOutlet weak var lblExpirationDate: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    
    // 커스텀 셀의 데이터 업데이트
    func update(info: DiffuserVO) {
        // 마지막 교체일과 오늘 날짜와의 차이
        let calendar = Calendar(identifier: .gregorian)
        let betweenDays = info.usersDays - calendar.numberOfDaysBetween(info.startDate, and: Date())
        lblTitle.text = info.title
        if betweenDays > 3 {
            lblRemainDayText.text = "\(betweenDays)일 후 교체 필요"
            self.contentView.backgroundColor = nil
        } else if betweenDays <= 3 && betweenDays > 0 {
            lblRemainDayText.text = "\(betweenDays)일 후 교체 필요"
            self.contentView.backgroundColor = #colorLiteral(red: 0.9773717523, green: 0.9611932635, blue: 0.7925902009, alpha: 1)
        } else {
            lblRemainDayText.text = "즉시 교체 필요!"
            self.contentView.backgroundColor = #colorLiteral(red: 0.9926608205, green: 0.8840166926, blue: 0.8681346178, alpha: 1)
        }
        
        
        // 마지막 교체일 또는 신규 등록일에 따라 레이블 구분 (교체, 설치? 등록?)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY년 MM월 dd일 교체됨"
        lblExpirationDate.text = dateFormatter.string(from: info.startDate)
        thumbnailView.image = getImage(fileNameWithExt: info.photoName)
        thumbnailView.layer.cornerRadius = 8
        thumbnailView?.clipsToBounds = true
        
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
    
    func addDiffuserInfo(diffuser: DiffuserVO) {
        diffuserInfoList.insert(diffuser, at: 0)
    }
    
    // test - 나중에 삭제
    func printViewModel() {
        print(diffuserInfoList)
    }
    
    func sortByStartDateDesc() {
        diffuserInfoList = diffuserInfoList.sorted { obj1, obj2 in
            let remainDay1 = betweenDays(usersDays: obj1.usersDays, startDate: obj1.startDate)
            let remainDay2 = betweenDays(usersDays: obj2.usersDays, startDate: obj2.startDate)
            return remainDay1 > remainDay2
        }
    }
    
    func sortByStartDateAsc() {
        diffuserInfoList = diffuserInfoList.sorted { obj1, obj2 in
            let remainDay1 = betweenDays(usersDays: obj1.usersDays, startDate: obj1.startDate)
            let remainDay2 = betweenDays(usersDays: obj2.usersDays, startDate: obj2.startDate)
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

extension CurrentViewController: DetailViewDelegate {
    func deleteFromList(_ controller: DiffuserDetailViewController, diffuser: DiffuserVO, index: Int) {
        self.viewModel.diffuserInfoList.remove(at: index)
        tblList.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            simpleAlert(self, message: "삭제 완료되었습니다.", title: "삭제 완료", handler: nil)
        }
    }
    
    func sendArchive(_ controller: DiffuserDetailViewController, diffuser: DiffuserVO, isModified: Bool, index: Int) {
        if isModified {
            print("sendarchive", index)
            viewModel.diffuserInfoList.remove(at: index)
            tblList.reloadData()
        }
    }
    
    func replaceModifiedDiffuser(_ controller: DiffuserDetailViewController, diffuser: DiffuserVO, isModified: Bool, index: Int) {
        if isModified {
            viewModel.diffuserInfoList[index] = diffuser
            tblList.reloadData()
        }
    }
    
}

// 노치 채우기
extension CurrentViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

// 애드몹 셋업
extension CurrentViewController {
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

}

extension CurrentViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("GAD: banner received.")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("GAD: receive failed.")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("GAD: bannerWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("GAD: bannerViewWillDismissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("GAD: bannerViewDidDismissScreen")
    }
    
}
