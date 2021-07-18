//
//  CurrentViewController.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/13.
//

import UIKit

class CurrentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddDelegate {
    
    var currentSelectedDiffuser: DiffuserVO? = nil
    
    @IBOutlet weak var tblList: UITableView!
    
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
        print(indexPath.row)
        currentSelectedDiffuser = viewModel.getDiffuserInfo(at: indexPath.row)
        performSegue(withIdentifier: "detailView", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let archiveAction = UITableViewRowAction(style: .normal, title: "Archive") { _, index in
            print("archavie")
        }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DTE") { _, index in
            simpleDestructiveYesAndNo(self, message: "정말 삭제하시겠습니까?", title: "삭제") { action in
                let deleteResult = deleteCoreData(id: self.viewModel.diffuserInfoList[indexPath.row].id)
                if deleteResult {
                    self.viewModel.diffuserInfoList.remove(at: (indexPath as NSIndexPath).row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
        return [deleteAction, archiveAction]
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
        

        // Do any additional setup after loading the view.
        do {
            try print(parsePlistExample())
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(UserDefaults.standard.string(forKey: "config-font") ?? "")
        do {
            let list = try readCoreData()
            print(list!)
        } catch {
            print(error)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print(segue.destination)
        if segue.identifier == "detailView" {
            guard let detailViewController = segue.destination as? DiffuserDetailViewController else { return }
            detailViewController.selectedDiffuser = currentSelectedDiffuser
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
        performSegue(withIdentifier: "layoutTest", sender: nil)
    }
    
    // AddDelegate
    func sendDiffuser(_ controller: DiffuserAddViewController, diffuser: DiffuserVO) {
        viewModel.addDiffuserInfo(diffuser: diffuser)
        tblList.reloadData()
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
        if betweenDays > 0 {
            lblRemainDayText.text = "\(betweenDays)일 후 교체 필요"
        } else {
            lblRemainDayText.text = "즉시 교체 필요!"
        }
        
        
        // 마지막 교체일 또는 신규 등록일에 따라 레이블 구분 (교체, 설치? 등록?)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY년 MM월 dd일 교체됨"
        lblExpirationDate.text = dateFormatter.string(from: info.startDate)
        
        thumbnailView.image = getImage(fileName: info.photoName)
        
    }
}

// MVVM 1: 뷰 모델 클래스 생성
class DiffuserViewModel {
    
    var diffuserInfoList: [DiffuserVO] = [
        DiffuserVO(title: "제 2회의실 탁자에 있는 엘레강스 디퓨저", startDate: Date(timeIntervalSince1970: 1625065200), comments: "", usersDays: 30, photoName: "", id: UUID()),
        DiffuserVO(title: "제 2회의실 TV 밑 선반에 있는 체리시 향의 디퓨저", startDate: Date(timeIntervalSince1970: 1623733399), comments: "", usersDays: 30, photoName: "", id: UUID()),
        DiffuserVO(title: "로비 위에 있는 섬유향 디퓨저", startDate: Date(timeIntervalSince1970: 1626066199), comments: "", usersDays: 30, photoName: "", id: UUID()),
        DiffuserVO(title: "복사기 옆에 있는 르네상스 디퓨저", startDate: Date(), comments: "", usersDays: 30, photoName: "", id: UUID()),
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
    
}
