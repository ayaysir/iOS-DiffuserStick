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
func saveToCoreData(_ title: String) {
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
    let person = NSManagedObject(entity: entity, insertInto: managedContext)
    
    // 3
    person.setValue(title, forKey: "name")
    
    
    // 4
    do {
        try managedContext.save()
        print(person)
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
    }
    
}

// 주로 viewWillAppear 에서 사용
func readFromCoreData() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    
    // 1
    let managedContext = appDelegate.persistentContainer.viewContext
    
    // 2
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
    
    do {
        let result = try managedContext.fetch(fetchRequest)
        print("array: \(result)")
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
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
