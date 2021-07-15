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
    let thumnail: UIImage?
    let photo: UIImage?
    
    init(title: String, startDate: Date) {
        self.title = title
        self.startDate = startDate
        self.id = "1"
        self.thumnail = #imageLiteral(resourceName: "diffuser")
        self.photo = #imageLiteral(resourceName: "diffuser")
    }
}
