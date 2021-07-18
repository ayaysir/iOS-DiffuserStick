//
//  DiffuserAddViewController.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/14.
//

import UIKit
import Photos

protocol AddDelegate {
    func sendDiffuser(_ controller: DiffuserAddViewController, diffuser: DiffuserVO)
}

class DiffuserAddViewController: UIViewController {
    
    var delegate: AddDelegate?

    @IBOutlet weak var inputTitle: UITextField!
    @IBOutlet weak var datepickerStartDate: UIDatePicker!
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var textComments: UITextView!
    @IBOutlet weak var lblDays: UILabel!
    @IBOutlet weak var stepperOutlet: UIStepper!
    
    var userDays: Int = UserDefaults.standard.integer(forKey: "config-defaultDays")
    
    // 사진: 이미지 피커 컨트롤러 생성
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 사진: 이미지 피커에 딜리게이트 생성
        imagePickerController.delegate = self
        
        // 사진, 카메라 권한 (최초 요청)
        PHPhotoLibrary.requestAuthorization { status in
            return
        }
        
        // 기본 일수
        if userDays < 15 {
            userDays = 15
        }
        lblDays.text = String(userDays)
        stepperOutlet.value = Double(userDays)
            
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: Any) {
        let uuid = UUID()
        let photoName = inputTitle.text!.convertToValidFileName() + "___" + uuid.uuidString
        let diffuser = DiffuserVO(title: inputTitle.text!, startDate: datepickerStartDate.date, comments: textComments.text, usersDays: userDays, photoName: photoName, id: UUID())
        let savePhotoResult = saveImage(image: imgPhoto.image!, fileName: photoName)
        let saveCDResult = saveCoreData(diffuserVO: diffuser)
        
        if delegate != nil {
            delegate?.sendDiffuser(self, diffuser: diffuser)
        }
        if savePhotoResult && saveCDResult{
            simpleAlert(self, message: "저장되었습니다.", title: "저장") { action in
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            simpleAlert(self, message: "저장이 되지 않았습니다. 다시 시도해주세요.")
        }
    }
    
    // 사진: 카메라 켜기 - 시뮬레이터에서는 카메라 사용이 불가능하므로 에러가 발생.
    @IBAction func btnTakePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePickerController.sourceType = .camera
            
            switch PHPhotoLibrary.authorizationStatus() {
            case .notDetermined:
                simpleAlert(self, message: "notDetermined")
                UIApplication.shared.open(URL(string: "UIApplication.openSettingsURLString")!)
            case .restricted:
                simpleAlert(self, message: "restricted")
            case .denied:
                simpleAlert(self, message: "denied")
            case .authorized:
                self.present(self.imagePickerController, animated: true, completion: nil)
            case .limited:
                simpleAlert(self, message: "limited")
            @unknown default:
                simpleAlert(self, message: "unknown")
            }
        } else {
            print("카메라 사용이 불가능합니다.")
            simpleAlert(self, message: "카메라 사용이 불가능합니다.")
        }
        
        /**
         switch PHPhotoLibrary.authorizationStatus() {
            .notDetermined - User has not yet made a choice with regards to this application
            .restricted - This application is not authorized to access photo data. The user cannot change this application’s status, possibly due to active restrictions
            .denied - User has explicitly denied this application access to photos data.
            .authorized - User has authorized this application to access photos data.

         }
         */
    }
    
    // 사진: 라이브러리 켜기
    @IBAction func btnLoadPhoto(_ sender: Any) {
        self.imagePickerController.sourceType = .photoLibrary
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            simpleAlert(self, message: "notDetermined")
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        case .restricted:
            simpleAlert(self, message: "restricted")
        case .denied:
            simpleAlert(self, message: "denied")
        case .authorized:
            self.present(self.imagePickerController, animated: true, completion: nil)
        case .limited:
            simpleAlert(self, message: "limited")
        @unknown default:
            simpleAlert(self, message: "unknown")
        }
    }
    
    @IBAction func stepperDaysAction(_ sender: Any) {
        userDays = Int(stepperOutlet.value)
        lblDays.text = String(userDays)
    }

}

// 사진: 딜리게이트 구현한 뷰 컨트롤러 생성
extension DiffuserAddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imgPhoto.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
}

extension DiffuserAddViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
