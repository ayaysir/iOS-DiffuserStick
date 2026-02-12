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
    items[0].title = "리스트"
    items[1].title = "보관함"
    items[2].title = "설정 및 도움말"
  }
}
