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

class DiffuserDetailViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLastChangedDate: UILabel!
    @IBOutlet weak var imgPhoto: UIImageView!
    
    var selectedDiffuser: DiffuserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = selectedDiffuser?.title
        imgPhoto.image = selectedDiffuser?.photo
        lblLastChangedDate.text = formatLastChanged(date: selectedDiffuser!.startDate)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
