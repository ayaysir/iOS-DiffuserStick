//
//  CleanupDocumentDirectoryUtil.swift
//  DiffuserStick
//
//  Created by 윤범태 on 3/1/24.
//

import Foundation

class CleanupDocumentDirectoryUtil {
  /// 1.3.0 이전 버전에서 삭제되지 않은 Document 디렉토리의 이미지 파일을 삭제
  func doCleanup() {
    let activeData = try? readCoreData(isArchive: false)
    let archiveData = try? readCoreData(isArchive: true)
    
    let documentDir = getDocumentsDirectory()
    var validImageFiles: [URL] = []
    
    if let activeData {
      activeData.forEach { diffuser in
        validImageFiles.append(documentDir.appendingPathComponent(diffuser.photoName))
        print(#function, "Added valid image file:", diffuser.photoName)
      }
    }
    
    if let archiveData {
      archiveData.forEach { diffuser in
        validImageFiles.append(documentDir.appendingPathComponent(diffuser.photoName))
        print(#function, "Added valid image file:", diffuser.photoName)
      }
    }
    
    do {
      // Get the directory contents urls (including subfolders urls)
      let directoryContents = try FileManager.default.contentsOfDirectory(
        at: documentDir,
        includingPropertiesForKeys: nil
      )
      
      directoryContents.forEach { url in
        if !validImageFiles.contains(url) {
          removeFile(from: url)
          print(#function, "This file has been disconnected from the database. Delete:", url.lastPathComponent)
        } else {
          print(#function, "This file is valid so we will not delete it:", url.lastPathComponent)
        }
      }
    } catch {
      print(#function, error)
    }
    
  }
}
