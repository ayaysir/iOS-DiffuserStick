//
//  DiffuserAddViewController.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/14.
//

import UIKit
import Photos

protocol AddDelegate {
    func sendDiffuser(_ controller: DiffuserAddViewController, diffuser: DiffuserInfo)
}

class DiffuserAddViewController: UIViewController {
    
    var delegate: AddDelegate?

    @IBOutlet weak var inputTitle: UITextField!
    @IBOutlet weak var datepickerStartDate: UIDatePicker!
    @IBOutlet weak var imgPhoto: UIImageView!
    
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
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: Any) {
        let diffuser = DiffuserInfo(title: inputTitle.text!, startDate: datepickerStartDate.date, comments: "ee", usersDays: 15)
        if delegate != nil {
            delegate?.sendDiffuser(self, diffuser: diffuser)
        }
        let saveResult = saveImage(image: imgPhoto.image!, fileName: diffuser.id)
        print(saveResult)
        dismiss(animated: true, completion: nil)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
