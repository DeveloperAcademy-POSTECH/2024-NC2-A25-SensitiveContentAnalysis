//
//  CoreDataManager.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/19/24.
//

import CoreData

final class CoreDataManager {
    
    static let shared: CoreDataManager = .init()
    
    private init() { }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photo")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext { return self.persistentContainer.viewContext }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print("저장실패: \(error.localizedDescription)")
            }
        }
    }
    
    @discardableResult
    func savePhoto(imageData: Data) -> Bool {
        let entity = NSEntityDescription.entity(forEntityName: "Photo",
                                                in: self.context)
        
        if let entity = entity {
            let managedObject = NSManagedObject(entity: entity, insertInto: self.context)
            managedObject.setValue(UUID(), forKey: "uuid")
            managedObject.setValue(imageData, forKey: "image")
            managedObject.setValue(Date(), forKey: "createdAt")
            do {
                try self.context.save()
                print("저장완료: \(managedObject)")
                return true
            } catch let error {
                print("저장실패: \(error.localizedDescription)")
                return false
            }
        } else {
            return false
        }
    }
    
    func fetchContext<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        do {
            let fetchResult = try self.context.fetch(request)
            return fetchResult
        } catch let error {
            print("로딩실패: \(error.localizedDescription)")
            return []
        }
    }
}
