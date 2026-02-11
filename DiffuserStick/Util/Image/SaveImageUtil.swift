//
//  SaveImageUtil.swift
//  DiffuserStick
//
//  Created by 윤범태 on 2/12/26.
//

import UIKit

enum ImageSaveLocation {
  case documents
  case applicationSupport(subdirectory: String? = nil)
  case appGroup(identifier: String, subdirectory: String? = nil)
}

func saveImage(
  _ image: UIImage,
  fileName: String,
  compressionQuality: CGFloat = 0.95,
  location: ImageSaveLocation
) -> (fileExt: String, url: URL)? {
  
  // 1. 이미지 데이터 변환
  guard let data = image.jpegData(compressionQuality: compressionQuality)
        ?? image.pngData() else {
    return nil
  }
  
  // 2. 기본 디렉토리 결정
  let baseDirectory: URL?
  
  switch location {
    
  case .documents:
    baseDirectory = FileManager.default
      .urls(for: .documentDirectory, in: .userDomainMask)
      .first
    
  case .applicationSupport(let subdirectory):
    let appSupportDir = FileManager.default
      .urls(for: .applicationSupportDirectory, in: .userDomainMask)
      .first
    if let subdirectory {
      baseDirectory = appSupportDir?.appendingPathComponent(subdirectory)
    } else {
      baseDirectory = appSupportDir
    }
      
  case .appGroup(let identifier, let subdirectory):
    let appGroupDir = FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: identifier)
    if let subdirectory {
      baseDirectory = appGroupDir?.appendingPathComponent(subdirectory)
    } else {
      baseDirectory = appGroupDir
    }
      
  }
  
  guard let directory = baseDirectory else {
    return nil
  }
  
  // 3. 디렉토리 생성
  if !FileManager.default.fileExists(atPath: directory.path) {
    do {
      try FileManager.default.createDirectory(
        at: directory,
        withIntermediateDirectories: true
      )
    } catch {
      print(#function, "createDirectory error:", error.localizedDescription)
      return nil
    }
  }
  
  // 4. 확장자 자동 결정
  let ext = data.format
  let finalFileName = fileName.hasSuffix(".\(ext)")
    ? fileName
    : "\(fileName).\(ext)"
  
  let fileURL = directory.appendingPathComponent(finalFileName)
  
  // 5. 저장
  do {
    try data.write(to: fileURL)
    return (ext, fileURL)
  } catch {
    print(#function, "write error:", error.localizedDescription)
    return nil
  }
}
