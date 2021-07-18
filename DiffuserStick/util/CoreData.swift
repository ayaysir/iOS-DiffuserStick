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
func readCoreData() throws -> [DiffuserVO]? {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
    
    // 1
    let managedContext = appDelegate.persistentContainer.viewContext
    
    // 2
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Diffuser")
    let sort = NSSortDescriptor(key: "startDate", ascending: false)
    fetchRequest.sortDescriptors = [sort]
    
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


func updateCoreData(id: UUID) throws {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    
    // 1
    let managedContext = appDelegate.persistentContainer.viewContext
    
    // 2
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Diffuser")
    fetchRequest.predicate = NSPredicate(format: "id = %@", id.uuidString)
    
    do {
        let result = try managedContext.fetch(fetchRequest)
        let objectToUpdate = result[0] as! NSManagedObject
        print("objectToUpdate: \(objectToUpdate)")
        print("oTU title: \(objectToUpdate.value(forKey: "title")!)")
        
    } catch let error as NSError {
        print("Could not update. \(error), \(error.userInfo)")
        throw error
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
        return true
    } catch let error as NSError {
        print("Could not update. \(error), \(error.userInfo)")
        return false
    }
}
