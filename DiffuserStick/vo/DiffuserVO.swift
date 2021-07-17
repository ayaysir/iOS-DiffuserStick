//
//  DiffuserInfo.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/13.
//

import UIKit

struct DiffuserVO {
    let id: UUID
    let title: String
    let startDate: Date
    let comments: String
    let usersDays: Int
    var photoName: String
    
    init(title: String, startDate: Date, comments: String, usersDays: Int, photoName: String, id: UUID) {
        self.title = title
        self.startDate = startDate
        self.id = id
        self.usersDays = usersDays
        self.comments = comments
        self.photoName = photoName
    }
}
