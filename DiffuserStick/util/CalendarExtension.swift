//
//  CalendarExtension.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/15.
//

import Foundation

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day!
    }
}

func betweenDays(usersDays: Int, startDate: Date) -> Int {
    let calendar = Calendar(identifier: .gregorian)
    return usersDays - calendar.numberOfDaysBetween(startDate, and: Date())
}
