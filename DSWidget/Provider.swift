//
//  Provider.swift
//  DiffuserStick
//
//  Created by 윤범태 on 2/11/26.
//

import WidgetKit

struct Provider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(
      date: Date(),
      diffuser: .mock,
      configuration: .init()
    )
  }
  
  func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
    let diffuser: DiffuserWidgetDTO = loadDiffusers(from: .shdDiffuserJSONFileName).first ?? .mock
    return SimpleEntry(date: .now, diffuser: diffuser, configuration: configuration)
  }
  
  func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
    let diffusers = loadDiffusers(from: .shdDiffuserJSONFileName)
    print("timeline:", diffusers)

    // 데이터가 없을 경우 mock 반환
    guard !diffusers.isEmpty else {
      let entry = SimpleEntry(
        date: Date(),
        diffuser: .mock,
        configuration: configuration
      )
      return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 15)))
    }

    // 현재 시각 기준으로 랜덤 선택
    let randomDiffuser = diffusers.randomElement()!

    let entry = SimpleEntry(
      date: Date(),
      diffuser: randomDiffuser,
      configuration: configuration
    )

    // 15분 후 다시 타임라인 요청 (화면을 자주 켤 경우 자연스럽게 변경됨)
    let nextUpdate = Date().addingTimeInterval(60 * 15)

    return Timeline(entries: [entry], policy: .after(nextUpdate))
  }
  
  //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
  //        // Generate a list containing the contexts this widget is relevant in.
  //    }
}
