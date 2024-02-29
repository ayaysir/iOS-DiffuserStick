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

let TEXT_VIEW_PLACEHOLDER_MSG = "메모를 입력해주세요."

class DiffuserAddViewController: UIViewController {
    
    var delegate: AddDelegate?
    var modifyDelegate: ModifyDelegate?
    var mode: String = "add"
    var selectedDiffuser: DiffuserVO?
    
    var isKeyboardAppeared: Bool = false
    var scrollViewY: CGFloat?
    var activeField: String?

    @IBOutlet weak var inputTitle: UITextField!
    @IBOutlet weak var datepickerStartDate: UIDatePicker!
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var textComments: UITextView!
    @IBOutlet weak var lblDays: UILabel!
    @IBOutlet weak var stepperOutlet: UIStepper!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnSaveOutlet: UIButton!
    
    var userDays: Int = UserDefaults.standard.integer(forKey: "config-defaultDays")
    
    // 사진: 이미지 피커 컨트롤러 생성
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollViewY = scrollView.frame.origin.y
        
        // 사진: 이미지 피커에 딜리게이트 생성
        imagePickerController.delegate = self
        
        // 사진, 카메라 권한 (최초 요청)
        PHPhotoLibrary.requestAuthorization { status in
            return
        }
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
            
        }
        
        // 키보드 DONE 버튼 추가
        inputTitle.addDoneButtonOnKeyboard()
        textComments.addDoneButton(title: "완료", target: self, selector: #selector(tapDone(sender:)))
        
        // 키보드 높이
        // Will 대신 Did를 사용한 이유는 TextField의 Edit Begin 을 감지하기 위함
        // https://stackoverflow.com/questions/65423793/
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // 버튼 둥글게
        btnSaveOutlet!.layer.cornerRadius = 0.5 * btnSaveOutlet!.bounds.size.width
        btnSaveOutlet!.clipsToBounds = true
        
        // 기본 일수
        if mode == "add" {
            if userDays < 15 {
                userDays = 30
            }
            lblDays.text = String(userDays)
            stepperOutlet.value = Double(userDays)
            textComments.text = TEXT_VIEW_PLACEHOLDER_MSG
            textComments.textColor = UIColor.lightGray
        } else if mode == "modify" {
            // modify 모드일 경우 컴포넌트에 기존 값을 표시해야 함
            userDays = selectedDiffuser!.usersDays
            lblDays.text = String(selectedDiffuser!.usersDays)
            print("userDays: \(userDays)")
            
            stepperOutlet.value = Double(selectedDiffuser!.usersDays)
            inputTitle.text = selectedDiffuser?.title
            datepickerStartDate.date = selectedDiffuser!.startDate
            imgPhoto.image = getImage(fileNameWithExt: selectedDiffuser!.photoName)
            if textComments.text == "" {
                textComments.text = TEXT_VIEW_PLACEHOLDER_MSG
                textComments.textColor = UIColor.lightGray
            } else {
                textComments.text = selectedDiffuser?.comments
            }
        
        }
        
        // 이미지 터치 추가
        
        
        print("mode: \(mode)")
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: Any) {
        // 유효성 검시
        if inputTitle.text == "" {
            simpleAlert(self, message: "제목은 1자 이상 입력해야 합니다.")
            return
        }
        
        if mode == "add" {
            let uuid = UUID()
            let photoNameWithoutExt = inputTitle.text!.convertToValidFileName() + "___" + uuid.uuidString
            guard let savePhotoResult = saveImage(image: imgPhoto.image!, fileNameWithoutExt: photoNameWithoutExt) else { return }
            
            let comments = (TEXT_VIEW_PLACEHOLDER_MSG != textComments.text ? textComments.text : "")!
            let diffuser = DiffuserVO(title: inputTitle.text!, startDate: datepickerStartDate.date, comments: comments, usersDays: userDays, photoName: photoNameWithoutExt + "." + savePhotoResult, id: uuid, createDate: Date(), isFinished: false)
            
            let saveCDResult = saveCoreData(diffuserVO: diffuser)
            
            if delegate != nil {
                delegate?.sendDiffuser(self, diffuser: diffuser)
            }
            if saveCDResult{
                simpleAlert(self, message: "저장되었습니다.", title: "저장") { action in
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
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                simpleAlert(self, message: "업데이트가 되지 않았습니다. 다시 시도해주세요.")
            }
            
        }
        
    }
    
    private func openSetting(action: UIAlertAction) -> Void {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }
    
    func doTaskByPhotoAuthorization() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            print("photo auth >>> not determined")
            simpleDestructiveYesAndNo(self, message: "사진 권한 설정을 변경하시겠습니까?", title: "권한 정보 없음", yesHandler: openSetting)
        case .restricted:
            print("photo auth >>> restricted")
            simpleAlert(self, message: "시스템에 의해 거부되었습니다.")
        case .denied:
            print("photo auth >>> denied")
            simpleDestructiveYesAndNo(self, message: "사진 기능 권한이 거부되어 사용할 수 없습니다. 사진 권한 설정을 변경하시겠습니까?", title: "권한 거부됨", yesHandler: openSetting(action:))
        case .authorized:
            print("photo auth >>> authorized")
            self.present(self.imagePickerController, animated: true, completion: nil)
        case .limited:
            print("photo auth >>> limited")
            self.present(self.imagePickerController, animated: true, completion: nil)
        @unknown default:
            print("photo auth >>> unknown")
            simpleAlert(self, message: "unknown")
        }
    }
    
    func doTaskByCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .notDetermined:
            print("camera auth >>> not determined")
            simpleDestructiveYesAndNo(self, message: "카메라 권한 설정을 변경하시겠습니까?", title: "권한 정보 없음", yesHandler: openSetting)
        case .restricted:
            print("camera auth >>> restricted")
            simpleAlert(self, message: "시스템에 의해 거부되었습니다.")
        case .denied:
            print("camera auth >>> denied")
            simpleDestructiveYesAndNo(self, message: "카메라 기능 권한이 거부되어 사용할 수 없습니다. 카메라 권한 설정을 변경하시겠습니까?", title: "권한 거부됨", yesHandler: openSetting(action:))
        case .authorized:
            print("camera auth >>> authorized")
            self.present(self.imagePickerController, animated: true, completion: nil)
        @unknown default:
            print("camera auth >>> unknown")
            simpleAlert(self, message: "unknown")
        }
    }
    
    // 사진: 카메라 켜기 - 시뮬레이터에서는 카메라 사용이 불가능하므로 에러가 발생.
    @IBAction func btnTakePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePickerController.sourceType = .camera
            doTaskByCameraAuthorization()
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
    
    @IBAction func btnThumb1(_ sender: Any) {
        imgPhoto.image = #imageLiteral(resourceName: "diffuser")
    }
    @IBAction func btnThumb2(_ sender: Any) {
        imgPhoto.image = #imageLiteral(resourceName: "diffuser2")
    }
    @IBAction func btnThumb3(_ sender: Any) {
        imgPhoto.image = #imageLiteral(resourceName: "diffuser3")
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
        textViewSetup(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textViewSetup(textView)
        }
    }
    
    func textViewSetup(_ textView: UITextView) {
        
        if textView.text == "" {
            textView.text = TEXT_VIEW_PLACEHOLDER_MSG
            textView.textColor = UIColor.lightGray
        } else if textView.text == TEXT_VIEW_PLACEHOLDER_MSG {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
}
