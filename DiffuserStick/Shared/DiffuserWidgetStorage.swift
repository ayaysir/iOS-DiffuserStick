//
//  DiffuserWidgetStorage.swift
//  DiffuserStick
//
//  Created by 윤범태 on 2/11/26.
//

import Foundation

func loadDiffusers(from fileName: String = .shdDiffuserJSONFileName) -> [DiffuserWidgetDTO] {
  guard let containerURL = FileManager.default
    .containerURL(forSecurityApplicationGroupIdentifier: .shdAppGroupIdentifier) else {
    return []
  }

  let fileURL = containerURL.appendingPathComponent(fileName)

  guard FileManager.default.fileExists(atPath: fileURL.path) else {
    return []
  }

  do {
    let data = try Data(contentsOf: fileURL)
    let decoder = JSONDecoder()
    // decoder.dateDecodingStrategy = .secondsSince1970
    return try decoder.decode([DiffuserWidgetDTO].self, from: data)
  } catch {
    print("Decoding error:", error)
    return []
  }
}

func saveDiffusersToAppGroup(diffuserWidgetDTOs dtos: [DiffuserWidgetDTO]) {
  // data 목록을 app group 폴더에 작성
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.prettyPrinted]
  
  guard let gContainer = FileManager.default.containerURL(
    forSecurityApplicationGroupIdentifier: .shdAppGroupIdentifier
  ) else {
    return
  }
  let url = gContainer.appendingPathComponent("ds-widget-data.json")
  
  do {
    let data = try encoder.encode(dtos)
    print("app group directory:", url)
    try? data.write(to: url, options: .atomic)
  } catch {
    print("Encoding error: \(error)")
  }
}
