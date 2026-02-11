//
//  CalendarExtension.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/15.
//

import Foundation

extension Calendar {
  /// from과 to 사이의 일수 차이 구함
  func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
    let fromDate = startOfDay(for: from)
    let toDate = startOfDay(for: to)
    let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
    
    return numberOfDays.day ?? -1
  }
}

extension Date {
  /// year, month, day로 구성된 DateComponents를 반환
  func toYMDDateComponent() -> DateComponents {
    return Calendar.current.dateComponents([.year, .month, .day], from: self)
  }
  
  /// userDays에서 (self(startDate)와 현재 날짜의 차이)를 뺀 값을 반환
  /// ```
  ///                              V 이 부분이 결과값
  /// self -------------- Date() [...............]
  /// |------------usersDays---------------------|
  /// ```
  /// - Parameter usersDays: 사용자가 설정한 디퓨저 교체 주기
  func diffuserDaysRemaining(totalDays: Int) -> Int {
    let calendar = Calendar(identifier: .gregorian)
    return totalDays - calendar.numberOfDaysBetween(self, and: Date())
  }
}

func dayToSecond(_ day: Int) -> TimeInterval {
  return TimeInterval(day) * 86400
}

