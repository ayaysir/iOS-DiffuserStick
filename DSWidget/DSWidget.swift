//
//  DSWidget.swift
//  DSWidget
//
//  Created by 윤범태 on 2/11/26.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
  }
  
  func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
    SimpleEntry(date: Date(), configuration: configuration)
  }
  
  func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
    var entries: [SimpleEntry] = []
    
    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
    let currentDate = Date()
    for hourOffset in 0 ..< 5 {
      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
      let entry = SimpleEntry(date: entryDate, configuration: configuration)
      entries.append(entry)
    }
    
    return Timeline(entries: entries, policy: .atEnd)
  }
  
  //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
  //        // Generate a list containing the contexts this widget is relevant in.
  //    }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationAppIntent
}

struct DSWidgetEntryView : View {
  var entry: Provider.Entry
  @Environment(\.widgetFamily) var family
  
  var body: some View {
    //   Text(entry.date, style: .time)
    //   Text(entry.configuration.favoriteEmoji)
    switch family {
    case .systemSmall:
      SmallView
    default:
      DefaultView
    }
  }
  
  @ViewBuilder private func ResizableRendered(imageView: Image) -> some View {
    if #available(iOS 18.0, *) {
      imageView
        .resizable()
        .widgetAccentedRenderingMode(.desaturated)
    } else {
      imageView
        .resizable()
    }
  }
  
  @ViewBuilder private var SmallView: some View {
    VStack() {
      HStack(spacing: 12) {
        ResizableRendered(imageView: Image(.jelly1))
          .scaledToFit()
          .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        VStack {
          Image(systemName: "clock.arrow.circlepath")
          Text("28일")
        }
      }
      Divider()
      Text("창가의 디퓨저 스틱")
        .font(.footnote)
        .fontWeight(.semibold)
      Text("2026년 2월 9일 교체됨")
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
  }
  
  @ViewBuilder private var DefaultView: some View {
    HStack(spacing: 16) {
      ResizableRendered(imageView: Image(.jelly1))
        .scaledToFit()
        .frame(width: 100)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
      VStack(alignment: .leading) {
        Text("창가의 디퓨저 스틱")
          .font(.title2)
          .bold()
        Divider()
          .opacity(0)
        Text("18일 후 교체 필요")
        Text("2026년 2월 9일 교체됨")
          .foregroundStyle(.secondary)
      }
      Spacer()
    }
  }
}

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
  fileprivate static var smiley: ConfigurationAppIntent {
    let intent = ConfigurationAppIntent()
    intent.favoriteEmoji = "😀"
    return intent
  }
  
  fileprivate static var starEyes: ConfigurationAppIntent {
    let intent = ConfigurationAppIntent()
    intent.favoriteEmoji = "🤩"
    return intent
  }
}

#Preview(as: .systemSmall) {
  DSWidget()
} timeline: {
  SimpleEntry(date: .now, configuration: .smiley)
  SimpleEntry(date: .now, configuration: .starEyes)
}
