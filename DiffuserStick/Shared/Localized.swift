//
//  Localized.swift
//  DiffuserStick
//
//  Created by 윤범태 on 2/12/26.
//

import Foundation

extension String {
  var localized: String {
    return NSLocalizedString(self, comment: "")
  }
  
  func localizedFormat(_ arguments: CVarArg...) -> String {
    let localizedValue = self.localized
    return String(format: localizedValue, arguments: arguments)
  }
}
