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

let TEXT_VIEW_PLACEHOLDER_MSG = "loc.write.memo.placeholder".localized

class DiffuserAddViewController: UIViewController {
  
  enum Mode {
    case add, modify, rewrite
  }
  
  var delegate: AddDelegate?
  var modifyDelegate: ModifyDelegate?
  
  var mode: Mode = .add
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
  
  @IBOutlet weak var lblTitleIntro: UILabel!
  @IBOutlet weak var lblTitleDesc: UILabel!
  @IBOutlet weak var lblImageUploadIntro: UILabel!
  @IBOutlet weak var btnCameraDesc: UIButton!
  @IBOutlet weak var btnLoadPhotoDesc: UIButton!
  @IBOutlet weak var lblStartDateIntro: UILabel!
  @IBOutlet weak var lblReplaceDaysIntro: UILabel!
  @IBOutlet weak var lblMemoIntro: UILabel!
  
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
    textComments.addDoneButton(title: "loc.common.complete".localized, target: self, selector: #selector(tapDone(sender:)))
    
    // 키보드 높이
    // Will 대신 Did를 사용한 이유는 TextField의 Edit Begin 을 감지하기 위함
    // https://stackoverflow.com/questions/65423793/
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    
    // 버튼 둥글게
    btnSaveOutlet!.layer.cornerRadius = 0.5 * btnSaveOutlet!.bounds.size.width
    btnSaveOutlet!.clipsToBounds = true
    
    // Localizable texts
    lblTitleIntro.text = "loc.write.title.intro".localized
    
    switch mode {
    case .add, .modify:
      lblTitleDesc.text = "loc.write.title.desc".localized
    case .rewrite:
      lblTitleDesc.text = "loc.write.title.desc.rewrite".localized
    }
    
    lblImageUploadIntro.text = "loc.write.image.upload.intro".localized
    btnCameraDesc.setTitle("loc.write.camera".localized, for: .normal)
    btnLoadPhotoDesc.setTitle("loc.write.photo.library".localized, for: .normal)
    lblStartDateIntro.text = "loc.write.start.date.intro".localized
    lblReplaceDaysIntro.text = "loc.write.replace.days.intro".localized
    lblMemoIntro.text = "loc.write.memo.intro".localized
    btnSaveOutlet.setTitle("loc.common.save".localized, for: .normal)
    
    switch mode {
    case .add:
      // 기본 일수
      if userDays < 15 {
        userDays = 30
      }
      lblDays.text = String(userDays)
      stepperOutlet.value = Double(userDays)
      textComments.text = TEXT_VIEW_PLACEHOLDER_MSG
      textComments.textColor = UIColor.lightGray
    case .modify, .rewrite:
      // modify/rewrite 모드일 경우 컴포넌트에 기존 값을 표시해야 함
      guard let diffuser = selectedDiffuser else {
        return
      }
      
      userDays = diffuser.usersDays
      lblDays.text = String(diffuser.usersDays)
      print("userDays: \(userDays)")
      
      stepperOutlet.value = Double(diffuser.usersDays)
      inputTitle.text = diffuser.title
      datepickerStartDate.date = diffuser.startDate
      imgPhoto.image = getImage(fileNameWithExt: diffuser.photoName)
      
      if textComments.text == "" {
        textComments.text = TEXT_VIEW_PLACEHOLDER_MSG
        textComments.textColor = UIColor.lightGray
      } else {
        textComments.text = diffuser.comments
      }
    }
    
    // 이미지 터치 추가 (??)
    print("mode: \(mode)")
  }
  
  @IBAction func btnClose(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func btnSave(_ sender: Any) {
    // 유효성 검사
    guard let inputTitleText = inputTitle.text, !inputTitleText.isEmpty else {
      simpleAlert(self, message: "loc.write.invalid.title.letter.count".localized)
      return
    }
    
    guard let image = imgPhoto.image else {
      simpleAlert(self, message: "loc.write.invalid.no.image".localized)
      return
    }
    
    switch mode {
    case .add, .rewrite:
      let uuid = UUID() // 새로운 아이디 부여
      let photoNameWithoutExt = inputTitleText.convertToValidFileName() + "___" + uuid.uuidString
      
      // guard let savePhotoResult = saveImage(image: image, fileNameWithoutExt: photoNameWithoutExt) else {
      guard let (ext, _) = saveImage(image, fileName: photoNameWithoutExt, location: .documents) else {
        simpleAlert(self, message: "loc.write.invalid.image.error".localized)
        return
      }
      
      let comments = TEXT_VIEW_PLACEHOLDER_MSG != textComments.text ? textComments.text ?? "" : ""
      let diffuser = DiffuserVO(
        title: inputTitleText,
        startDate: datepickerStartDate.date,
        comments: comments,
        usersDays: userDays,
        photoName: photoNameWithoutExt + "." + ext,
        id: uuid,
        createDate: Date(),
        isFinished: false
      )
      
      let saveCDResult = saveCoreData(diffuserVO: diffuser)
      
      if mode == .add, let addDelegate = delegate {
        addDelegate.sendDiffuser(self, diffuser: diffuser)
      } else if mode == .rewrite {
        NotificationCenter.default.post(name: .didRewriteDiffuserPush, object: diffuser)
      }
      
      if saveCDResult {
        simpleAlert(self, message: "loc.alert.save.complete.message".localized, title: "loc.common.save".localized) { action in
          self.dismiss(animated: true, completion: nil)
        }
      } else {
        simpleAlert(self, message: "loc.alert.save.failed.message".localized)
      }
    case .modify:
      guard var diffuser = selectedDiffuser else {
        return
      }
      
      let uuid = diffuser.id
      diffuser.title = inputTitle.text!
      diffuser.startDate = datepickerStartDate.date
      diffuser.comments = textComments.text
      diffuser.usersDays = userDays
      
      // 유효성 검사: 일수
      if userDays < 15 {
        simpleAlert(self, message: "교체 일수는 15일 미만일 수가 없습니다.")
        return
      }
      
      let oldPhotoNameWithExt = diffuser.photoName
      let modifiedPhotoNameWithoutExt = inputTitleText.convertToValidFileName() + "___" + uuid.uuidString
      
      // guard let savePhotoResult = saveImage(image: image, fileNameWithoutExt: modifiedPhotoNameWithoutExt) else {
      guard let (ext, _) = saveImage(image, fileName: modifiedPhotoNameWithoutExt, location: .documents) else {
        simpleAlert(self, message: "loc.write.invalid.image.error".localized)
        return
      }
      diffuser.photoName = modifiedPhotoNameWithoutExt + "." + ext
      
      if oldPhotoNameWithExt != diffuser.photoName {
        removeImageFileFromDocument(fileNameIncludesExtension: oldPhotoNameWithExt)
      }
      
      if let modifyDelegate = modifyDelegate {
        modifyDelegate.sendDiffuser(self, diffuser: diffuser)
      }
      
      let updateCDResult = updateCoreData(id: uuid, diffuserVO: diffuser)
      
      if updateCDResult {
        simpleAlert(self, message: "loc.alert.update.complete.message".localized, title: "loc.alert.update.complete.title".localized) { action in
          self.dismiss(animated: true, completion: nil)
        }
      } else {
        simpleAlert(self, message: "loc.alert.update.failed.message".localized)
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
      let message = "loc.alert.photo.auth.not_determined.message".localized
      let title = "loc.alert.photo.auth.not_determined.title".localized
      simpleDestructiveYesAndNo(self, message: message, title: title, yesHandler: openSetting)
    case .restricted:
      let message = "loc.alert.photo.auth.restricted.message".localized
      simpleAlert(self, message: message)
    case .denied:
      let message = "loc.alert.photo.auth.denied.message".localized
      let title = "loc.alert.photo.auth.denied.title".localized
      simpleDestructiveYesAndNo(self, message: message, title: title, yesHandler: openSetting(action:))
    case .authorized:
      self.present(self.imagePickerController, animated: true, completion: nil)
    case .limited:
      self.present(self.imagePickerController, animated: true, completion: nil)
    @unknown default:
      simpleAlert(self, message: "unknown")
    }
  }
  
  func doTaskByCameraAuthorization() {
    switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
    case .notDetermined:
      let message = "loc.alert.camera.auth.not_determined.message".localized
      let title = "loc.alert.photo.auth.not_determined.title".localized
      simpleDestructiveYesAndNo(self, message: message, title: title, yesHandler: openSetting)
    case .restricted:
      let message = "loc.alert.photo.auth.restricted.message".localized
      simpleAlert(self, message: message)
    case .denied:
      let message = "loc.alert.camera.auth.denied.message".localized
      let title = "loc.alert.photo.auth.denied.title".localized
      simpleDestructiveYesAndNo(self, message: message, title: title, yesHandler: openSetting(action:))
    case .authorized:
      self.present(self.imagePickerController, animated: true, completion: nil)
    @unknown default:
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
