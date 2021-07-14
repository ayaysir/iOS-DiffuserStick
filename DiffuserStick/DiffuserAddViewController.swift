//
//  DiffuserAddViewController.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/14.
//

import UIKit

protocol AddDelegate {
    func sendDiffuser(_ controller: DiffuserAddViewController, diffuser: DiffuserInfo)
}

class DiffuserAddViewController: UIViewController {
    
    var delegate: AddDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: Any) {
        let diffuser = DiffuserInfo(title: "rktks", startDate: Date())
        print(delegate)
        if delegate != nil {
            delegate?.sendDiffuser(self, diffuser: diffuser)
        }
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
