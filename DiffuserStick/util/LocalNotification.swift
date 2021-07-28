//
//  LocalNotification.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/28.
//

import Foundation
import UIKit

// 공통 : 알림(푸시) 설정
// 알림 전송
func addPushNoti(diffuser: DiffuserVO) {
    // Local push
    let userNotiCenter = UNUserNotificationCenter.current()
    
    userNotiCenter.removePendingNotificationRequests(withIdentifiers: [diffuser.id.uuidString])
    let notiContent = UNMutableNotificationContent()
    notiContent.title = diffuser.title
    notiContent.body = "'\(diffuser.title)' 디퓨저의 스틱을 교체해야 합니다."
    notiContent.userInfo = ["targetScene": "change", "diffuserId": diffuser.id.uuidString] // 푸시 받을때 오는 데이터
    notiContent.categoryIdentifier = "image-message"
    
    // 이미지 집어넣기
    do {
        let imageThumbnail = makeImageThumbnail(image: getImage(fileNameWithExt: diffuser.photoName)!)!
        let imageUrl = saveImageToTempDir(image: imageThumbnail, fileName: diffuser.photoName)
        let attach = try UNNotificationAttachment(identifier: "", url: imageUrl!, options: nil)
        notiContent.attachments.append(attach)
    } catch {
        print(error)
    }
    
    var trigger: UNNotificationTrigger
    if Bundle.main.object(forInfoDictionaryKey: "TestMode") as! Bool {
         // 알림이 trigger되는 시간 설정 - Test
//        trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
        let addedDate = Date().addingTimeInterval(10)
        var alarmDateComponents = Calendar.current.dateComponents([.second, .month, .day, .hour, .minute, .year], from: addedDate)
        alarmDateComponents.hour = 19
        alarmDateComponents.minute = 51
        alarmDateComponents.second = 30
        print("NSNoti reserved date: (test) >>>", alarmDateComponents as Any)
        
        // Create the trigger as a repeating event.
        trigger = UNCalendarNotificationTrigger(dateMatching: alarmDateComponents, repeats: false)
        
    } else {
        // Configure the recurring date.
        let addedDate = Date().addingTimeInterval(dayToSecond(diffuser.usersDays))
        var alarmDateComponents = Calendar.current.dateComponents([.second, .month, .day, .hour, .minute, .year], from: addedDate)
        alarmDateComponents.hour = 15
        alarmDateComponents.minute = 30
        alarmDateComponents.second = 0

        print("NSNoti reserved date: ", alarmDateComponents as Any)

        // Create the trigger as a repeating event.
        trigger = UNCalendarNotificationTrigger(dateMatching: alarmDateComponents, repeats: true)
    }

    let request = UNNotificationRequest(
        identifier: diffuser.id.uuidString,
        content: notiContent,
        trigger: trigger
    )

    userNotiCenter.add(request) { (error) in
        print("notification >>>", request, error as Any)
        print("noti time zone >>>")
    }
}

func removePushNoti(id: UUID) {
    let userNotiCenter = UNUserNotificationCenter.current()
    userNotiCenter.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
}
