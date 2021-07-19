//
//  DiffuserInfo.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/13.
//

import UIKit

struct DiffuserVO {
    let id: UUID
    var title: String
    var startDate: Date
    var comments: String
    var usersDays: Int
    var photoName: String
    let createDate: Date
    var isFinished: Bool
    
    init(title: String, startDate: Date, comments: String,
         usersDays: Int, photoName: String, id: UUID, createDate: Date, isFinished: Bool) {
        self.title = title
        self.startDate = startDate
        self.id = id
        self.usersDays = usersDays
        self.comments = comments
        self.photoName = photoName
        self.createDate = createDate
        self.isFinished = isFinished
    }
}
