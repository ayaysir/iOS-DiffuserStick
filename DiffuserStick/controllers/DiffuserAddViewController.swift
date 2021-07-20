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
    
    var isKeyboardAppeared: Bool = false
    var scrollViewY: CGFloat?
    var activeField: String?
    
    // Local push
    let userNotiCenter = UNUserNotificationCenter.current()

    @IBOutlet weak var inputTitle: UITextField!
    @IBOutlet weak var datepickerStartDate: UIDatePicker!
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var textComments: UITextView!
    @IBOutlet weak var lblDays: UILabel!
    @IBOutlet weak var stepperOutlet: UIStepper!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var userDays: Int = UserDefaults.standard.integer(forKey: "config-defaultDays")
    
    // 사진: 이미지 피커 컨트롤러 생성
    let imagePickerController = UIImagePickerController()
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("scrollveiw", scrollView.frame.origin)
        scrollViewY = scrollView.frame.origin.y
        
        // 사진: 이미지 피커에 딜리게이트 생성
        imagePickerController.delegate = self
        
        // 사진, 카메라 권한 (최초 요청)
        PHPhotoLibrary.requestAuthorization { status in
            return
        }
        
        // 키보드 DONE 버튼 추가
        textComments.addDoneButton(title: "완료", target: self, selector: #selector(tapDone(sender:)))
        
        // 키보드 높이
        // Will 대신 Did를 사용한 이유는 TextField의 Edit Begin 을 감지하기 위함
        // https://stackoverflow.com/questions/65423793/
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // 기본 일수
        if mode == "add" {
            if userDays < 15 {
                userDays = 15
            }
            lblDays.text = String(userDays)
            stepperOutlet.value = Double(userDays)
        } else if mode == "modify" {
            // modify 모드일 경우 컴포넌트에 기존 값을 표시해야 함
            userDays = selectedDiffuser!.usersDays
            lblDays.text = String(selectedDiffuser!.usersDays)
            print("userDays: \(userDays)")
            
            stepperOutlet.value = Double(selectedDiffuser!.usersDays)
            inputTitle.text = selectedDiffuser?.title
            datepickerStartDate.date = selectedDiffuser!.startDate
            imgPhoto.image = getImage(fileNameWithExt: selectedDiffuser!.photoName)
            textComments.text = selectedDiffuser?.comments
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
            
            // 유효성 검사: 일수
            if userDays < 15 {
                simpleAlert(self, message: "교체 일수는 15일 미만일 수가 없습니다.")
                return
            }
            
            let modifiedPhotoNameWithoutExt = inputTitle.text!.convertToValidFileName() + "___" + uuid.uuidString
            let savePhotoResult = saveImage(image: imgPhoto.image!, fileNameWithoutExt: modifiedPhotoNameWithoutExt)
            selectedDiffuser?.photoName = modifiedPhotoNameWithoutExt + "." + savePhotoResult!
            
            
            if modifyDelegate != nil {
                modifyDelegate?.sendDiffuser(self, diffuser: selectedDiffuser!)
            }
            
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
    
    func doTaskByPhotoAuthorization() {
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
    }
    
    // 사진: 카메라 켜기 - 시뮬레이터에서는 카메라 사용이 불가능하므로 에러가 발생.
    @IBAction func btnTakePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePickerController.sourceType = .camera
            doTaskByPhotoAuthorization()
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
        doTaskByPhotoAuthorization()
    }
    
    @IBAction func stepperDaysAction(_ sender: Any) {
        userDays = Int(stepperOutlet.value)
        lblDays.text = String(userDays)
    }
    
    func addKeyboardNotifications(){
        // 키보드가 나타날 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotifications(){
        // 키보드가 나타날 때 앱에게 알리는 메서드 제거
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 제거
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    // 키보드가 나타났다는 알림을 받으면 실행할 메서드
    @objc func keyboardWillShow(_ sender: NSNotification) {
        if activeField == "title" {
            isKeyboardAppeared = true
            return
        }
        if isKeyboardAppeared == false {
            let userInfo: NSDictionary = sender.userInfo! as NSDictionary
            let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            isKeyboardAppeared = true
            self.view.frame.origin.y -= keyboardHeight
            print("keyboardWillShow", self.view.frame.origin.y, self.scrollView.frame.origin.y)
            
        }
        
    }
    // 키보드가 사라졌다는 알림을 받으면 실행할 메서드
    @objc func keyboardWillHide(_ sender: NSNotification){
        if activeField == "title" {
            isKeyboardAppeared = false
            return
        }
        if isKeyboardAppeared == true {
            let userInfo: NSDictionary = sender.userInfo! as NSDictionary
            let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.frame.origin.y += keyboardHeight
            self.scrollView.frame.origin.y = scrollViewY!
            isKeyboardAppeared = false
            print("keyboardWillHide", self.view.frame.origin.y, self.scrollView.frame.origin.y)
        }
    }

    @objc func tapDone(sender: Any) {
        self.view.endEditing(true)
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = "title"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension DiffuserAddViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeField = "comment"
    }
    
}
