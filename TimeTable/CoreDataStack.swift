//
//  CoreDataStack.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2017/01/03.
//  Copyright © 2017年 Shuhei Fujita. All rights reserved.
//

import UIKit
import CoreData
import Ensembles

class CoreDataStack: NSObject, CDEPersistentStoreEnsembleDelegate {

    static let shared: CoreDataStack = {
        let instance = CoreDataStack()
        return instance
    }()
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.SFcreate.TimeTable" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        return NSManagedObjectModel(contentsOf: self.modelURL)!
    }()
    
    lazy var storeURL: URL = {
        return self.applicationDocumentsDirectory.appendingPathComponent("TimeTable.sqlite")
    }()
    
    lazy var modelURL: URL = {
        return Bundle.main.url(forResource: self.storeName, withExtension: "momd")!
    }()
    
    lazy var storeName: String = {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var failureReason = "There was an error creating or loading the application's saved data."
        let options: [AnyHashable: Any] = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Ensembles
    var cloudFileSystem: CDECloudFileSystem!
    var ensemble: CDEPersistentStoreEnsemble!
    
    func enableEnsembles() {
        cloudFileSystem = CDEICloudFileSystem(ubiquityContainerIdentifier: nil)
        ensemble = CDEPersistentStoreEnsemble(ensembleIdentifier: self.storeName, persistentStore: storeURL, managedObjectModelURL: modelURL, cloudFileSystem: cloudFileSystem)
        ensemble.delegate = self
    }
    
    func persistentStoreEnsemble(_ ensemble: CDEPersistentStoreEnsemble, didSaveMergeChangesWith notification: Notification) {
        managedObjectContext.performAndWait {
            self.managedObjectContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func sync(completion: (() -> Void)?) {
        if !ensemble.isLeeched {
            ensemble.leechPersistentStore {
                error in
                completion?()
            }
        } else {
            ensemble.merge {
                error in
                completion?()
            }
        }
    }
}
