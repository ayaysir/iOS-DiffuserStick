//
//  DSWidgetEntryView.swift
//  DiffuserStick
//
//  Created by 윤범태 on 2/11/26.
//

import WidgetKit
import SwiftUI

struct DSWidgetEntryView : View {
  var entry: Provider.Entry
  @Environment(\.widgetFamily) var family
  
  var body: some View {
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
        .widgetAccentedRenderingMode(entry.configuration.isFullColorImage ? .fullColor : .desaturated)
    } else {
      imageView
        .resizable()
    }
  }
  
  @ViewBuilder private var SmallView: some View {
    VStack {
      HStack(spacing: 12) {
        ResizableRendered(imageView: Image(.jelly1))
          .scaledToFit()
          .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        VStack {
          Image(systemName: "clock.arrow.circlepath")
          Text(verbatim: betweenDaysText)
        }
      }
      Divider()
      Text(verbatim: entry.diffuser.title)
        .font(.footnote)
        .fontWeight(.semibold)
      Text(verbatim: formatLastChanged)
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
  }
  
  @ViewBuilder private var DefaultView: some View {
    let diffuser = entry.diffuser
    HStack(spacing: 16) {
      ResizableRendered(imageView: Image(.jelly1))
        .scaledToFit()
        .frame(width: 100)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
      VStack(alignment: .leading) {
        Text(verbatim: diffuser.title)
          .font(.title2)
          .bold()
        Divider()
          .opacity(0)
        HStack {
          Text(verbatim: betweenDaysText)
        }
        Text(verbatim: formatLastChanged)
          .foregroundStyle(.secondary)
          .font(.footnote)
      }
      Spacer()
    }
  }
  
  private var formatLastChanged: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY년 M월 dd일 교체됨"
    return formatter.string(from: entry.diffuser.lastStartDate)
  }
  
  // TODO: - remainingDays만 변수로 해서 텍스트 로직 교체
  private var betweenDaysText: String {
    let remainingDays = entry.diffuser.lastStartDate
      .diffuserDaysRemaining(totalDays: entry.diffuser.usersDays)

    if remainingDays <= 0 {
      switch family {
      case .systemSmall:
        return "즉시\n교체"
      default:
        return "즉시 교체 필요"
      }
    }

    switch family {
    case .systemSmall:
      return "\(remainingDays)일"
    default:
      return "\(remainingDays)일 후 교체 필요"
    }
  }

}

#Preview(as: .systemSmall) {
  DSWidget()
} timeline: {
  SimpleEntry(date: .now, diffuser: .mock, configuration: .fullColor)
}
