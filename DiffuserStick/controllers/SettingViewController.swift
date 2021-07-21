//
//  SettingViewController.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/15.
//

import UIKit
import MessageUI

func refreshDefaultDaysOfConfig(_ num: Int) {
    UserDefaults.standard.setValue(num, forKey: "config-defaultDays")
}

class SettingViewController: UIViewController {
    
    @IBOutlet weak var stepperDaysOutlet: UIStepper!
    @IBOutlet weak var lblDays: UILabel!
    
    // 폰트 리스트의 이름들 저장 배열
    var availableFontList = [String]()
    
    var currentDays = UserDefaults.standard.integer(forKey: "config-defaultDays")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblDays.text = String(Int(stepperDaysOutlet.value))
        
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
    
    @IBAction func stepperDays(_ sender: Any) {
        let days = Int(stepperDaysOutlet.value)
        lblDays.text = String(days)
        refreshDefaultDaysOfConfig(days)
    }
    
}

extension SettingViewController: MFMailComposeViewControllerDelegate {
    @IBAction func launchEmail(sender: AnyObject) {
        
        guard MFMailComposeViewController.canSendMail() else {
            print("Mail services are not available")
            return
        }
        
        let emailTitle = "Feedback"
        let messageBody = "Feature request or bug report?"
        let toRecipents = ["friend@stackoverflow.com"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        
        self.present(mc, animated: true, completion: nil)
    }
    
//    private func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
//        switch result {
//        case .cancelled:
//            print("Mail cancelled")
//        case .saved:
//            print("Mail saved")
//        case .sent:
//            print("Mail sent")
//        case .failed:
//            print("Mail sent failure: \(error.localizedDescription)")
//        default:
//            break
//        }
//        self.dismiss(animated: true, completion: nil)
//    }
    
    @objc(mailComposeController:didFinishWithResult:error:)
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,error: Error?) {
            controller.dismiss(animated: true)
        }
    
}
