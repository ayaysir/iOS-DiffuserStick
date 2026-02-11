//
//  DSWidget.swift
//  DSWidget
//
//  Created by 윤범태 on 2/11/26.
//

import WidgetKit
import SwiftUI

struct DSWidget: Widget {
  let kind: String = "DSWidget"
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind,
      intent: ConfigurationAppIntent.self,
      provider: Provider()
    ) { entry in
      DSWidgetEntryView(entry: entry)
        .containerBackground(.fill.quaternary, for: .widget)
    }
    .supportedFamilies([.systemSmall, .systemMedium])
    .configurationDisplayName(Text("DiffuserStick 위젯"))
    .description(Text("교체해야할 디퓨저 목록을 확인할 수 있습니다."))
  }
}

extension ConfigurationAppIntent {
  static var fullColor: ConfigurationAppIntent {
    let intent = ConfigurationAppIntent()
    intent.isFullColorImage = false
    return intent
  }
}
