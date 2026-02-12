//
//  MainTabBarController.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/13.
//

import UIKit

class MainTabBarController: UITabBarController {
  override func viewDidLoad() {
    // testOnlyInstantNoti()
    
    guard let items = tabBar.items else {
      return
    }
    
    // Localizable texts
    items[0].title = "loc.main.tab.item.list".localized
    items[1].title = "loc.main.tab.item.archive".localized
    items[2].title = "loc.main.tab.item.settings".localized
  }
}
