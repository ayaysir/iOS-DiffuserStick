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
protocol ModifyDelegate {
    func sendDiffuser(_ controller: DiffuserAddViewController, diffuser: DiffuserVO)
}

class DiffuserAddViewController: UIViewController {
    
    var delegate: AddDelegate?
    var modifyDelegate: ModifyDelegate?
    var mode: String = "add"
    var selectedDiffuser: DiffuserVO?
    
    // Local push
    let userNotiCenter = UNUserNotificationCenter.current()

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
        if mode == "add" {
            if userDays < 15 {
                userDays = 15
            }
            lblDays.text = String(userDays)
            stepperOutlet.value = Double(userDays)
        } else if mode == "modify" {
            // modify 모드일 경우 컴포넌트에 기존 값을 표시해야 함
            inputTitle.text = selectedDiffuser?.title
            datepickerStartDate.date = selectedDiffuser!.startDate
            imgPhoto.image = getImage(fileNameWithExt: selectedDiffuser!.photoName)
            textComments.text = selectedDiffuser?.comments
            lblDays.text = String(selectedDiffuser!.usersDays)
            stepperOutlet.value = Double(selectedDiffuser!.usersDays)
        }
        
        print("mode: \(mode)")
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: Any) {
        if mode == "add" {
            let uuid = UUID()
            let photoNameWithoutExt = inputTitle.text!.convertToValidFileName() + "___" + uuid.uuidString
            guard let savePhotoResult = saveImage(image: imgPhoto.image!, fileNameWithoutExt: photoNameWithoutExt) else { return }
            
            let diffuser = DiffuserVO(title: inputTitle.text!, startDate: datepickerStartDate.date, comments: textComments.text, usersDays: userDays, photoName: photoNameWithoutExt + "." + savePhotoResult, id: uuid, createDate: Date(), isFinished: false)
            print(diffuser.photoName)
            let saveCDResult = saveCoreData(diffuserVO: diffuser)
            
            if delegate != nil {
                delegate?.sendDiffuser(self, diffuser: diffuser)
            }
            if saveCDResult{
                simpleAlert(self, message: "저장되었습니다.", title: "저장") { action in
                    self.addPushNoti(diffuser: diffuser)
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                simpleAlert(self, message: "저장이 되지 않았습니다. 다시 시도해주세요.")
            }
        } else if mode == "modify" {
            let uuid = selectedDiffuser!.id
            selectedDiffuser?.title = inputTitle.text!
            selectedDiffuser?.startDate = datepickerStartDate.date
            selectedDiffuser?.comments = textComments.text
            selectedDiffuser?.usersDays = userDays
            selectedDiffuser?.photoName = inputTitle.text!.convertToValidFileName() + "___" + uuid.uuidString
            
            if modifyDelegate != nil {
                modifyDelegate?.sendDiffuser(self, diffuser: selectedDiffuser!)
            }
            
            let savePhotoResult = saveImage(image: imgPhoto.image!, fileNameWithoutExt: selectedDiffuser!.photoName)
            let updateCDResult = updateCoreData(id: uuid, diffuserVO: selectedDiffuser!)
            
            if (savePhotoResult != nil) && updateCDResult {
                simpleAlert(self, message: "업데이트 되었습니다.", title: "업데이트") { action in
                    self.addPushNoti(diffuser: self.selectedDiffuser!)
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                simpleAlert(self, message: "업데이트가 되지 않았습니다. 다시 시도해주세요.")
            }
            
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
    
    // 공통 : 알림(푸시) 설정
    // 알림 전송
    func addPushNoti(diffuser: DiffuserVO) {
        userNotiCenter.removePendingNotificationRequests(withIdentifiers: [diffuser.id.uuidString])
        let notiContent = UNMutableNotificationContent()
        notiContent.title = diffuser.title
        notiContent.body = "'\(diffuser.title)' 디퓨저의 스틱을 교체해야 합니다."
        notiContent.userInfo = ["targetScene": "change", "diffuserId": diffuser.id.uuidString] // 푸시 받을때 오는 데이터
        notiContent.categoryIdentifier = "image-message"
        
        // 이미지 집어넣기
        do {
            let imageThumbnail = makeImageThumbnail(image: imgPhoto.image!)!
            let imageUrl = saveImageToTempDir(image: imageThumbnail, fileName: diffuser.photoName)
            let attach = try UNNotificationAttachment(identifier: "", url: imageUrl!, options: nil)
            notiContent.attachments.append(attach)
        } catch {
            print(error)
        }
         // 알림이 trigger되는 시간 설정
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
        
        // Configure the recurring date.
//        var dateComponents = DateComponents()
//        dateComponents.day = userDays
//        let alarmDate = Calendar.current.date(byAdding: dateComponents, to: diffuser.startDate)
//        var alarmDateComponents = Calendar.current.dateComponents(in: .current, from: alarmDate!)
//        alarmDateComponents.hour = 15
//        alarmDateComponents.minute = 10
//        alarmDateComponents.second = 0
//        print(alarmDateComponents as Any)
//
//        // Create the trigger as a repeating event.
//        let trigger = UNCalendarNotificationTrigger(
//            dateMatching: alarmDateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: diffuser.id.uuidString,
            content: notiContent,
            trigger: trigger
        )

        userNotiCenter.add(request) { (error) in
            print(#function, error as Any)
        }
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
