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
func saveToCoreData(diffuserVO diffuser: DiffuserVO) -> Bool {
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
    let managedContext = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "Diffuser", in: managedContext)!
    let diffuserCD = NSManagedObject(entity: entity, insertInto: managedContext)
    
    // 3
    diffuserCD.setValue(diffuser.comments, forKey: "comments")
    diffuserCD.setValue(diffuser.id, forKey: "id")
    diffuserCD.setValue(diffuser.photoName, forKey: "photoName")
    diffuserCD.setValue(diffuser.startDate, forKey: "startDate")
    diffuserCD.setValue(diffuser.title, forKey: "title")
    diffuserCD.setValue(diffuser.usersDays, forKey: "usersDays")
    
    // 4
    do {
        try managedContext.save()
        return true
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
        return false
    }
    
}

// 주로 viewWillAppear 에서 사용
func readFromCoreData() throws -> [DiffuserVO]? {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
    
    // 1
    let managedContext = appDelegate.persistentContainer.viewContext
    
    // 2
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Diffuser")
    
    do {
        let resultCDArray = try managedContext.fetch(fetchRequest)
        let voArray = resultCDArray.map { cdObject -> DiffuserVO in
            let id: UUID = cdObject.value(forKey: "id") as! UUID
            let title: String = cdObject.value(forKey: "title") as! String
            let startDate: Date = cdObject.value(forKey: "startDate") as! Date
            let comments: String = cdObject.value(forKey: "comments") as! String
            let usersDays: Int = cdObject.value(forKey: "usersDays") as! Int
            let photoName: String = cdObject.value(forKey: "photoName") as! String
            return DiffuserVO(title: title, startDate: startDate, comments: comments, usersDays: usersDays, photoName: photoName, id: id)
        }
        
        return voArray
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
        throw error
    }
}



//// 데이터를 저장하는 시점에 사용
//func saveDiffuserToCoreData(diffuserInfo: DiffuserInfo) {
//
//    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//    let managedContext = appDelegate.persistentContainer.viewContext
//    let entity = NSEntityDescription.entity(forEntityName: "Diffuser", in: managedContext)!
//    let diffuser = NSManagedObject(entity: entity, insertInto: managedContext) as? Diffuser
//
//    // 3
//    diffuser?.comments = diffuserInfo.comments
//
//
//
//    // 4
//    do {
//        try managedContext.save()
//        print(person)
//    } catch let error as NSError {
//        print("Could not save. \(error), \(error.userInfo)")
//    }
//
//}
//
//// 주로 viewWillAppear 에서 사용
//func readDiffusersFromCoreData() {
//    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//
//    // 1
//    let managedContext = appDelegate.persistentContainer.viewContext
//
//    // 2
//    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
//
//    do {
//        let result = try managedContext.fetch(fetchRequest)
//        print("array: \(result)")
//    } catch let error as NSError {
//        print("Could not save. \(error), \(error.userInfo)")
//    }
//}
