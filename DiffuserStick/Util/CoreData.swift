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
        let diffuserCD = result[0] as! Diffuser
        
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
        let objectToDelete = result[0] as! Diffuser
        
        // fileName: 확장자까지 포함되어 있음
        if let fileNameIncludesExtension = objectToDelete.photoName {
            removeImageFileFromDocument(fileNameIncludesExtension: fileNameIncludesExtension)
        }
        
        managedContext.delete(objectToDelete)
        try managedContext.save()
        removePushNoti(id: id)
        
        
        
        return true
    } catch let error as NSError {
        print("Could not update. \(error), \(error.userInfo)")
        return false
    }
}
