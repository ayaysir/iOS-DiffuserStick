//
//  DetailViewDelegate.swift
//  DiffuserStick
//
//  Created by 윤범태 on 2/9/26.
//

import Foundation

protocol DetailViewDelegate {
  func replaceModifiedDiffuser(
    _ controller: DiffuserDetailViewController,
    diffuser: DiffuserVO,
    isModified: Bool,
    index: Int
  )
  
  func sendArchive(
    _ controller: DiffuserDetailViewController,
    diffuser: DiffuserVO,
    isModified: Bool,
    index: Int
  )
  
  func deleteFromList(
    _ controller: DiffuserDetailViewController,
    diffuser: DiffuserVO,
    index: Int
  )
}

protocol ArchiveDetailViewDelegate {
  func deleteFromList(
    _ controller: DiffuserDetailViewController,
    diffuser: DiffuserVO,
    index: Int
  )
}
