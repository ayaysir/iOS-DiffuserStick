//
//  DiffuserDetailViewController.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/14.
//

import UIKit

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

protocol DetailViewDelegate {
    func replaceModifiedDiffuser(_ controller: DiffuserDetailViewController, diffuser: DiffuserVO, isModified: Bool, index: Int)
}

class DiffuserDetailViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLastChangedDate: UILabel!
    @IBOutlet weak var lblFutureChangeDate: UILabel!
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var lblRemainDays: UILabel!
    @IBOutlet weak var textComments: UITextView!
    
    var selectedDiffuser: DiffuserVO?
    var currentArrayIndex: Int?
    var delegate: DetailViewDelegate?
    var isDiffuserModified: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        lblTitle.text = selectedDiffuser?.title
        imgPhoto.image = getImage(fileName: selectedDiffuser!.photoName)
        lblLastChangedDate.text = formatLastChanged(date: selectedDiffuser!.startDate)
        lblFutureChangeDate.text = formatFutureChange(date: selectedDiffuser!.startDate, addDay: selectedDiffuser!.usersDays)
        textComments.text = selectedDiffuser!.comments
        
        // 마지막 교체일과 오늘 날짜와의 차이
        let calendar = Calendar(identifier: .gregorian)
        let betweenDays = selectedDiffuser!.usersDays - calendar.numberOfDaysBetween(selectedDiffuser!.startDate, and: Date())
        
        if betweenDays > 0 {
            lblRemainDays.text = "\(betweenDays)일 후 교체 필요"
        } else {
            lblRemainDays.text = "교체일이 지났습니다. 당장 교체해야 합니다!"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.replaceModifiedDiffuser(self, diffuser: selectedDiffuser!, isModified: isDiffuserModified, index: currentArrayIndex!)
    }
    
    @IBAction func btnClose(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnModify(_ sender: Any) {
        performSegue(withIdentifier: "modifyView", sender: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "modifyView" {
            guard let modifyViewController = segue.destination as? DiffuserAddViewController else { return }
            modifyViewController.mode = "modify"
            modifyViewController.selectedDiffuser = selectedDiffuser
            modifyViewController.modifyDelegate = self
        }
    }
}

extension DiffuserDetailViewController: ModifyDelegate {
    func sendDiffuser(_ controller: DiffuserAddViewController, diffuser: DiffuserVO) {
        // 먼저 detail view의 내용을 갱신하고
        selectedDiffuser = diffuser
        // view model의 vo 도 교체한다.
        isDiffuserModified = true
        
    }
}
