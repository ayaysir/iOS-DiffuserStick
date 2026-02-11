//
//  AppIntent.swift
//  DSWidget
//
//  Created by 윤범태 on 2/11/26.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
  static var title: LocalizedStringResource { "Configuration" }
  static var description: IntentDescription { "This is an example widget." }
  
  // An example configurable parameter.
  @Parameter(title: "이미지를 풀 컬러로 보기", default: false)
  var isFullColorImage: Bool
}
