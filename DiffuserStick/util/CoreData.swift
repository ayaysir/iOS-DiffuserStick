//
//  CoreData.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/16.
//

import Foundation
import UIKit
import CoreData

// 데이터를 저장하는 시점에 사용
func saveCoreData(diffuserVO diffuser: DiffuserVO) -> Bool {
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
    let managedContext = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "Diffuser", in: managedContext)!
    let diffuserCD = NSManagedObject(entity: entity, insertInto: managedContext)
    
    diffuserCD.setValue(diffuser.comments, forKey: "comments")
    diffuserCD.setValue(diffuser.id, forKey: "id")
    diffuserCD.setValue(diffuser.photoName, forKey: "photoName")
    diffuserCD.setValue(diffuser.startDate, forKey: "startDate")
    diffuserCD.setValue(diffuser.title, forKey: "title")
    diffuserCD.setValue(diffuser.usersDays, forKey: "usersDays")
    diffuserCD.setValue(diffuser.createDate, forKey: "createDate")
    diffuserCD.setValue(diffuser.isFinished, forKey: "isFinished")
    
    do {
        try managedContext.save()
        addPushNoti(diffuser: diffuser)
        return true
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
        return false
    }
    
}

// 주로 viewWillAppear 에서 사용
func readCoreData(isArchive: Bool = false) throws -> [DiffuserVO]? {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
    
    // 1
    let managedContext = appDelegate.persistentContainer.viewContext
    
    // 2
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Diffuser")
    let sort = NSSortDescriptor(key: "createDate", ascending: false)
    fetchRequest.sortDescriptors = [sort]
    
    fetchRequest.predicate = NSPredicate(format: "isFinished = %@", NSNumber(value: isArchive))
    
    do {
        let resultCDArray = try managedContext.fetch(fetchRequest)
        let voArray = resultCDArray.map { cdObject -> DiffuserVO in
            let id: UUID = cdObject.value(forKey: "id") as! UUID
            let title: String = cdObject.value(forKey: "title") as! String
            let startDate: Date = cdObject.value(forKey: "startDate") as! Date
            let comments: String = cdObject.value(forKey: "comments") as! String
            let usersDays: Int = cdObject.value(forKey: "usersDays") as! Int
            let photoName: String = cdObject.value(forKey: "photoName") as! String
            let createDate = cdObject.value(forKey: "createDate") ?? Date()
            let isFinished = cdObject.value(forKey: "isFinished") ?? false
            return DiffuserVO(title: title, startDate: startDate, comments: comments, usersDays: usersDays, photoName: photoName, id: id, createDate: createDate as! Date, isFinished: isFinished as! Bool)
        }
        
        return voArray
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
        throw error
    }
}


func updateCoreData(id: UUID, diffuserVO diffuser: DiffuserVO) -> Bool {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
    
    // 1
    let managedContext = appDelegate.persistentContainer.viewContext
    
    // 2
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Diffuser")
    fetchRequest.predicate = NSPredicate(format: "id = %@", id.uuidString)
    
    // 기존 Push 삭제
    
    
    do {
        let result = try managedContext.fetch(fetchRequest)
        let diffuserCD = result[0] as! NSManagedObject
        
        diffuserCD.setValue(diffuser.comments, forKey: "comments")
        diffuserCD.setValue(diffuser.photoName, forKey: "photoName")
        diffuserCD.setValue(diffuser.startDate, forKey: "startDate")
        diffuserCD.setValue(diffuser.title, forKey: "title")
        diffuserCD.setValue(diffuser.usersDays, forKey: "usersDays")
        diffuserCD.setValue(diffuser.createDate, forKey: "createDate")
        diffuserCD.setValue(diffuser.isFinished, forKey: "isFinished")
        
        try managedContext.save()
        if !diffuser.isFinished {
            addPushNoti(diffuser: diffuser)
        } else {
            removePushNoti(id: diffuser.id)
        }
        return true
    } catch let error as NSError {
        print("Could not update. \(error), \(error.userInfo)")
        return false
    }
}

func deleteCoreData(id: UUID) -> Bool {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
    
    // 1
    let managedContext = appDelegate.persistentContainer.viewContext
    
    // 2
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Diffuser")
    fetchRequest.predicate = NSPredicate(format: "id = %@", id.uuidString)
    
    do {
        let result = try managedContext.fetch(fetchRequest)
        let objectToDelete = result[0] as! NSManagedObject
        managedContext.delete(objectToDelete)
        try managedContext.save()
        removePushNoti(id: id)
        return true
    } catch let error as NSError {
        print("Could not update. \(error), \(error.userInfo)")
        return false
    }
}

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
    
     // 알림이 trigger되는 시간 설정 - Test
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
    
    // Configure the recurring date.
//        var dateComponents = DateComponents()
//        dateComponents.day = userDays
//        let alarmDate = Calendar.current.date(byAdding: dateComponents, to: diffuser.startDate)
//        var alarmDateComponents = Calendar.current.dateComponents(in: .current, from: alarmDate!)
//        alarmDateComponents.hour = 15
//        alarmDateComponents.minute = 10
//        alarmDateComponents.second = 0
//        print(alarmDateComponents as Any)
//
//        // Create the trigger as a repeating event.
//        let trigger = UNCalendarNotificationTrigger(
//            dateMatching: alarmDateComponents, repeats: true)

    let request = UNNotificationRequest(
        identifier: diffuser.id.uuidString,
        content: notiContent,
        trigger: trigger
    )

    userNotiCenter.add(request) { (error) in
        print(#function, error as Any)
    }
}

func removePushNoti(id: UUID) {
    let userNotiCenter = UNUserNotificationCenter.current()
    userNotiCenter.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
}
