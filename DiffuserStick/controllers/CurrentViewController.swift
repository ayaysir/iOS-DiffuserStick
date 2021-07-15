//
//  CurrentViewController.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/13.
//

import UIKit

class CurrentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddDelegate {
    
    var currentSelectedDiffuser: DiffuserInfo? = nil
    
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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do {
            try print(parsePlistExample())
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(UserDefaults.standard.string(forKey: "config-font") ?? "")
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
    
    // AddDelegate
    func sendDiffuser(_ controller: DiffuserAddViewController, diffuser: DiffuserInfo) {
        print("a")
        print("넘어온거", diffuser)
        viewModel.addDiffuserInfo(diffuser: diffuser)
        tblList.reloadData()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class DiffuserListCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblRemainDayText: UILabel!
    @IBOutlet weak var lblExpirationDate: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    
    // 커스텀 셀의 데이터 업데이트
    func update(info: DiffuserInfo) {
        lblTitle.text = info.title
        lblRemainDayText.text = "30일 후 교체 필요"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY년 MM월 dd일 만료"
        lblExpirationDate.text = dateFormatter.string(from: info.startDate)
        
        thumbnailView.image = info.thumnail
    }
}

// MVVM 1: 뷰 모델 클래스 생성
class DiffuserViewModel {
    var diffuserInfoList: [DiffuserInfo] = [
        DiffuserInfo(title: "제 2회의실 탁자에 있는 엘레강스 디퓨저", startDate: Date()),
        DiffuserInfo(title: "제 2회의실 TV 밑 선반에 있는 체리시 향의 디퓨저", startDate: Date()),
        DiffuserInfo(title: "로비 위에 있는 섬유향 디퓨저", startDate: Date()),
        DiffuserInfo(title: "복사기 옆에 있는 르네상스 디퓨저", startDate: Date()),
    ]
    
    var numOfDiffuserInfoList: Int {
        return diffuserInfoList.count
    }
    
    func getDiffuserInfo(at index: Int) -> DiffuserInfo {
        return diffuserInfoList[index]
    }
    
    func addDiffuserInfo(diffuser: DiffuserInfo) {
        diffuserInfoList.insert(diffuser, at: 0)
    }
    
    // test - 나중에 삭제
    func printViewModel() {
        print(diffuserInfoList)
    }
    
}
