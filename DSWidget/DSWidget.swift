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
    .configurationDisplayName(Text(.locWidgetConfigTitle))
    .description(Text(.locWidgetConfigDescription))
  }
}

extension ConfigurationAppIntent {
  static var fullColor: ConfigurationAppIntent {
    let intent = ConfigurationAppIntent()
    intent.isFullColorImage = false
    return intent
  }
}
