//
//  SettingViewController.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/15.
//

import UIKit



class SettingViewController: UIViewController {

    @IBOutlet weak var lblFontExample: UILabel!
    @IBOutlet weak var pkvAvailableFontList: UIPickerView!
    
    // 폰트 리스트의 이름들 저장 배열
    var availableFontList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 시스템의 모든 폰트 불러오기
        for family in UIFont.familyNames {
            print("\(family)")
            availableFontList.append(family)
            
            for name in UIFont.fontNames(forFamilyName: family) {
                print("\t\(name)")
            }
        }
        // Do any additional setup after loading the view.
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
