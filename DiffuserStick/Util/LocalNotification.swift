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
  // 이미 있는 노티 지우기
  userNotiCenter.removePendingNotificationRequests(withIdentifiers: [diffuser.id.uuidString])
  let notiContent = getNotiContent(of: diffuser, userNotiCenter: userNotiCenter)
  
  // 이미지 집어넣기
  // 알람이 나타나면 이미지가 삭제됨 -> 원본 넣으면 안됨
  guard let image = getImage(fileNameWithExt: diffuser.photoName),
        let thumb = makeImageThumbnail(image: image, maxPixelSize: 300),
        // let imageUrl = saveImageToAppSupportDir(image: thumb, fileName: diffuser.photoName)
        let (_, imageUrl) = saveImage(thumb, fileName: diffuser.photoName, location: .applicationSupport(subdirectory: nil))
  else {
    return
  }
  
  do {
    let attach = try UNNotificationAttachment(identifier: "", url: imageUrl, options: nil)
    notiContent.attachments.append(attach)
    print("Attached: \(attach)")
  } catch {
    print("Can't attach image:", error)
  }
  
  var trigger: UNNotificationTrigger
  if Bundle.main.object(forInfoDictionaryKey: "TestMode") as! Bool {
    trigger = getTestModeTrigger()
  } else {
    // Configure the recurring date.
    let addedDate = diffuser.startDate.addingTimeInterval(dayToSecond(diffuser.usersDays))
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

private func getNotiContent(
  of diffuser: DiffuserVO,
  userNotiCenter: UNUserNotificationCenter
) -> UNMutableNotificationContent {
  let notiContent = UNMutableNotificationContent()
  notiContent.title = diffuser.title
  notiContent.body = "'\(diffuser.title)' 디퓨저의 스틱을 교체해야 합니다."
  notiContent.userInfo = [
    "targetScene": "change",
    "diffuserId": diffuser.id.uuidString
  ] // 푸시 받을때 오는 데이터
  notiContent.sound = UNNotificationSound(named: .init("DFFE.wav"))
  notiContent.categoryIdentifier = "image-message"
  
  return notiContent
}

private func getTestModeTrigger() -> UNNotificationTrigger {
  // 알림이 trigger되는 시간 설정 - Test
  return UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
  
  // let addedDate = Date().addingTimeInterval(10)
  // var alarmDateComponents = Calendar.current.dateComponents([.second, .month, .day, .hour, .minute, .year], from: addedDate)
  // alarmDateComponents.hour = 19
  // alarmDateComponents.minute = 51
  // alarmDateComponents.second = 30
  // print("NSNoti reserved date: (test) >>>", alarmDateComponents as Any)
  
  // Create the trigger as a repeating event.
  // return UNCalendarNotificationTrigger(dateMatching: alarmDateComponents, repeats: false)
}

/// 테스트 전용 알람
func testOnlyInstantNoti() {
  // Local push
  let userNotiCenter = UNUserNotificationCenter.current()
  let notiContent = getNotiContent(
    of: DiffuserVO(
      title: "테스트 디퓨저",
      startDate: Date(),
      comments: "테스트",
      usersDays: 30,
      photoName: "",
      id: .init(),
      createDate: Date(),
      isFinished: false
    ),
    userNotiCenter: userNotiCenter
  )
 
  let trigger = UNTimeIntervalNotificationTrigger(
    timeInterval: 10.0, // 10초 후 알람
    repeats: false
  )
  
  let request = UNNotificationRequest(
    identifier: "test",
    content: notiContent,
    trigger: trigger
  )
  
  userNotiCenter.add(request) { (error) in
    print("notification >>>", request, error as Any)
    print("noti time zone >>>")
  }
}
