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
  static var description: IntentDescription { "DiffuserStick Widget Config" }
  
  // An example configurable parameter.
  @Parameter(title: "widget_isFullColorImage_title", default: false)
  var isFullColorImage: Bool
}
