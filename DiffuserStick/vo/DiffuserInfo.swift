//
//  DiffuserInfo.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/13.
//

import UIKit

struct DiffuserInfo {
    let id: String
    let title: String
    let startDate: Date
    
    let comments: String
    let usersDays: Int
    
    init(title: String, startDate: Date, comments: String, usersDays: Int) {
        self.title = title
        self.startDate = startDate
        self.id = UUID().uuidString
        self.usersDays = usersDays
        self.comments = comments
    }
}
