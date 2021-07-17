//
//  SettingViewController.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/15.
//

import UIKit

func refreshDefaultDaysOfConfig(_ num: Int) {
    UserDefaults.standard.setValue(num, forKey: "config-defaultDays")
}

class SettingViewController: UIViewController {

    @IBOutlet weak var lblFontExample: UILabel!
    @IBOutlet weak var pkvAvailableFontList: UIPickerView!
    @IBOutlet weak var stepperDaysOutlet: UIStepper!
    @IBOutlet weak var lblDays: UILabel!
    
    // 폰트 리스트의 이름들 저장 배열
    var availableFontList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblDays.text = String(Int(stepperDaysOutlet.value))
        
        // 일수 세팅
        let currentDays = UserDefaults.standard.integer(forKey: "config-defaultDays")
        if currentDays >= 15 {
            stepperDaysOutlet.value = Double(currentDays)
        } else {
            stepperDaysOutlet.value = 30.0
        }
        lblDays.text = String(currentDays)
        
        // userdefault 맨 처음 값은?
        // integer: 0, string: nil
        print(UserDefaults.standard.integer(forKey: "not-exist"))
        

        // 시스템의 모든 폰트 불러오기
        for family in UIFont.familyNames {
            availableFontList.append(family)
        }
    }
    
    @IBAction func stepperDays(_ sender: Any) {
        let days = Int(stepperDaysOutlet.value)
        lblDays.text = String(days)
        UserDefaults.standard.setValue(days, forKey: "config-defaultDays")
    }
    

    
}

extension SettingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // 컴포넌트 (열) 의 개수
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 행의 개수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableFontList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 특정 폰트를 선택했을 때, label 의 폰트가 바뀌도록
        lblFontExample.font = UIFont(name: availableFontList[row], size: lblFontExample.font.pointSize)
        UserDefaults.standard.set(availableFontList[row], forKey: "config-font")
    }
    
    // 피커뷰 행에 폰트 목록 표시
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.font = UIFont(name: availableFontList[row], size: CGFloat(20))
        pickerLabel.text = availableFontList[row]
        pickerLabel.textAlignment = .center
        return pickerLabel
    }
    
}

extension SettingViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
