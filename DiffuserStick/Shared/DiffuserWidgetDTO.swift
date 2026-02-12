//
//  DiffuserWidgetDTO.swift
//  DiffuserStick
//
//  Created by 윤범태 on 2/11/26.
//

import Foundation

struct DiffuserWidgetDTO: Codable {
  // 섬네일 파일 이름: 아이디.png
  let id: UUID
  var title: String
  var lastStartDate: Date
  var usersDays: Int
}

extension DiffuserWidgetDTO {
  static let mock: DiffuserWidgetDTO = .init(
    id: UUID(),
    title: "loc.widget.dto.mock.title".localized,
    lastStartDate: Date(),
    usersDays: 30
  )
}
