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
    Group {
      switch family {
      case .systemSmall:
        SmallView
      default:
        DefaultView
      }
    }
    .widgetURL(URL(string: "diffuserstick://detail?id=\(entry.diffuser.id.uuidString)"))
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
        let uiImage = getImageFromAppGroupDir(diffuserId: entry.diffuser.id) ?? .sample
        ResizableRendered(imageView: Image(uiImage: uiImage))
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
      let uiImage = getImageFromAppGroupDir(diffuserId: entry.diffuser.id) ?? .sample
      ResizableRendered(imageView: Image(uiImage: uiImage))
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
    formatter.dateFormat = "loc.common.replace.date.formatted".localized
    return formatter.string(from: entry.diffuser.lastStartDate)
  }
  
  // TODO: - remainingDays만 변수로 해서 텍스트 로직 교체
  private var betweenDaysText: String {
    let remainingDays = entry.diffuser.lastStartDate
      .diffuserDaysRemaining(totalDays: entry.diffuser.usersDays)

    if remainingDays <= 0 {
      switch family {
      case .systemSmall:
        return "loc.widget.replace.now.small".localized
      default:
        return "loc.common.need.replace.now".localized
      }
    }

    switch family {
    case .systemSmall:
      return "loc.common.day.formatted".localizedFormat(remainingDays)
    default:
      return "loc.common.need.replace".localizedFormat(remainingDays)
    }
  }
}

#Preview(as: .systemSmall) {
  DSWidget()
} timeline: {
  SimpleEntry(date: .now, diffuser: .mock, configuration: .fullColor)
}
