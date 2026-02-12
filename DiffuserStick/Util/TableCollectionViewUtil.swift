//
//  UITableViewUtil.swift
//  DiffuserStick
//
//  Created by 윤범태 on 2/29/24.
//

import UIKit

protocol TableCollectionBackgroundDisplayable {
  func displayBackgroundMessage(_ message: String)
  func dismissBackgroundMessage()
}

extension TableCollectionBackgroundDisplayable {
  func setBackgroundLabel(_ message: String, frame: CGRect) -> UILabel {
    let messageLabel = UILabel(frame: frame)
    messageLabel.text = message
    messageLabel.textColor = .darkGray
    messageLabel.numberOfLines = 0
    messageLabel.textAlignment = .center
    messageLabel.font = .systemFont(ofSize: 15)
    messageLabel.sizeToFit()
    
    return messageLabel
  }
}

extension UITableView: TableCollectionBackgroundDisplayable {
  /// 테이블 뷰에 메시지 표시 (예: 데이터가 없을 때 메시지 표시 등)
  func displayBackgroundMessage(_ message: String) {
    let labelFrame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
    
    self.backgroundView = setBackgroundLabel(message, frame: labelFrame)
    self.separatorStyle = .none
  }
  
  func dismissBackgroundMessage() {
    self.backgroundView = nil
    self.separatorStyle = .singleLine
  }
}

extension UICollectionView: TableCollectionBackgroundDisplayable {
  /// 테이블 뷰에 메시지 표시 (예: 데이터가 없을 때 메시지 표시 등)
  func displayBackgroundMessage(_ message: String) {
    let labelFrame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
    
    self.backgroundView = setBackgroundLabel(message, frame: labelFrame)
  }
  
  func dismissBackgroundMessage() {
    self.backgroundView = nil
  }
}
