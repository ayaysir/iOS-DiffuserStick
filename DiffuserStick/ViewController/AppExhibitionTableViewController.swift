//
//  AppExhibitionTableViewController.swift
//  DiffuserStick
//
//  Created by 윤범태 on 2/29/24.
//

import UIKit
import StoreKit

struct AppInfo {
  var title, description, imgAssetName, appStoreID: String
  
  var localizedTitle: String { title }
  var localizedDescription: String { description }
}

class AppExhibitionTableViewController: UITableViewController {
  private let infos: [AppInfo] = [
    AppInfo(title: "Music Interval Quiz Master",
            description: "음정 공부를 퀴즈, 악보, 소리와 함께 쉽게 마스터하세요!",
            imgAssetName: "icon-IntervalQuiz",
            appStoreID: "6738980588"),
    AppInfo(title: "UltimateScale",
            description: "UtimateScale은 다양한 키를 지원하는 내장 신디사이저 키보드와, 퀴즈를 통한 효율적인 학습이 가능한 스케일(음계) 학습 도우미입니다.",
            imgAssetName: "icon-UltimateScale",
            appStoreID: "1631310626"),
    AppInfo(title: "Make My MusicBox",
            description: "iPhone/iPad에서 뮤직박스가 다시 태어났습니다. 나만의 오르골과 악보를 만들어보세요.",
            imgAssetName: "icon-MusicBox",
            appStoreID: "1596583920"),
    AppInfo(title: "Tuner XR",
            description: "Tuner XR(Tuner with eXtRa features)은 보컬, 악기 등을 연주하는 음악가들을 위한 튜너 앱입니다.",
            imgAssetName: "icon-TunerXR",
            appStoreID: "1581803256"),
    // AppInfo(title: "DiffuserStick",
    //         description: "디퓨저 스틱(막대기) 교체 주기 관리 도우미 앱으로, 디퓨저의 사진과 함께 디퓨저 스틱을 꽂은 날을 기록하고, 교체 기간이 되면 푸시 알람을 통해 알려줍니다.",
    //         imgAssetName: "icon-DiffuserStick",
    //         appStoreID: "1578285458"),
    
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "BGSMM이 만든 다른 앱 보기"
    tableView.register(AppInfoCell.self, forCellReuseIdentifier: AppInfoCell.cellId)
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return infos.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: AppInfoCell.cellId, for: indexPath) as! AppInfoCell
    
    let info = infos[indexPath.row]
    cell.configure(info)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    popupAppStore(identifier: infos[indexPath.row].appStoreID)
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    120
  }
}

extension AppExhibitionTableViewController: SKStoreProductViewControllerDelegate {
  
  func popupAppStore(identifier: Any) {
    // 1631310626
    let parametersDictionary = [SKStoreProductParameterITunesItemIdentifier: identifier]
    let store = SKStoreProductViewController()
    store.delegate = self
    
    /*
     Attempt to load the selected product from the App Store. Display the store product view controller if success and print an error message,
     otherwise.
     */
    store.loadProduct(withParameters: parametersDictionary) { [unowned self] (result: Bool, error: Error?) in
      if result {
        self.present(store, animated: true, completion: {
          print("The store view controller was presented.")
        })
      } else {
        if let error = error {
          print(#function, "Error: \(error)")
        }
        
        if let url = URL(string: "https://apps.apple.com/app/tuner-xr/id\(identifier)") {
          UIApplication.shared.open(url)
        }
      }
    }
  }
}


class AppInfoCell: UITableViewCell {
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  /*
   row height: 120
   
   Constraints
   
   • Img View App Icon.leading = leading
   • bottom = Img View App Icon.bottom + 15
   • Img View App Icon.top = top + 15
   • trailing = Lbl Title.trailing
   • Lbl Title.top = top + 15
   • Lbl Title.leading = Img View App Icon.trailing + 12
   • bottom ≥ Lbl Description.bottom + 15
   • Lbl Description.trailing = Lbl Title.trailing
   • Lbl Description.leading = Lbl Title.leading
   • Lbl Description.top = Lbl Title.bottom
   */
  
  static let cellId = "AppInfoCell"
  
  private let imgViewAppIcon = UIImageView()
  private let lblTitle = UILabel()
  private let lblDescription = UILabel()
  
  func configure(_ info: AppInfo) {
    self.addSubview(imgViewAppIcon)
    self.addSubview(lblTitle)
    self.addSubview(lblDescription)
    
    lblTitle.font = .systemFont(ofSize: 22, weight: .bold)
    lblDescription.font = .systemFont(ofSize: 14)
    
    imgViewAppIcon.translatesAutoresizingMaskIntoConstraints = false
    lblTitle.translatesAutoresizingMaskIntoConstraints = false
    lblDescription.translatesAutoresizingMaskIntoConstraints = false
    
    [
      imgViewAppIcon.widthAnchor.constraint(equalToConstant: 90),
      imgViewAppIcon.heightAnchor.constraint(equalToConstant: 90),
      imgViewAppIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
      imgViewAppIcon.topAnchor.constraint(equalTo: topAnchor, constant: 15),
      
      lblTitle.leadingAnchor.constraint(equalTo: imgViewAppIcon.trailingAnchor, constant: 12),
      lblTitle.heightAnchor.constraint(equalToConstant: 30),
      lblTitle.topAnchor.constraint(equalTo: topAnchor, constant: 15),
      lblTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
      
      lblDescription.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 15),
      lblDescription.topAnchor.constraint(equalTo: lblTitle.bottomAnchor),
      lblDescription.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor),
      lblDescription.trailingAnchor.constraint(equalTo: lblTitle.trailingAnchor),
    ].forEach { $0.isActive = true }
    
    imgViewAppIcon.image = UIImage(named: info.imgAssetName)
    imgViewAppIcon.contentMode = .scaleAspectFit
    
    lblTitle.text = info.localizedTitle
    
    lblDescription.text = info.localizedDescription
    lblDescription.numberOfLines = 0
    lblDescription.lineBreakMode = .byWordWrapping
    lblDescription.sizeToFit()
  }
}
