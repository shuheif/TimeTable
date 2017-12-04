//
//  SettingViewModel.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 6/12/17.
//  Copyright © 2017 Shuhei Fujita. All rights reserved.
//

import Foundation
import CoreData
import EventKit

class SettingViewModel {
    
    static let shared: SettingViewModel = {
        let instance = SettingViewModel()
        return instance
    }()
    
    let userDefaults = UserDefaults.standard
    let defaultStack = CoreDataStack.shared
    let eventStore = EventStore.shared
    
    // Delete all Datas
    func deleteAllData() {
        
        let managedObjectContext = CoreDataStack.shared.managedObjectContext
        deleteAllTimetables(managedObjectContext: managedObjectContext)
        deleteAllClasses(managedObjectContext: managedObjectContext)
        deleteAllCourseTimes(managedObjectContext: managedObjectContext)
        deleteAllEvents(managedObjectContext: managedObjectContext)
    }
    
    
    func deleteAllTimetables(managedObjectContext: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<Timetables>
        if #available(iOS 10.0, *) {
            fetchRequest = Timetables.fetchRequest()
        } else {
            fetchRequest = NSFetchRequest(entityName: "Timetables")
        }
        do {
            let timetableObjects = try managedObjectContext.fetch(fetchRequest)
            for object in timetableObjects {
                managedObjectContext.delete(object)
            }
        } catch let error {
            print(error.localizedDescription)
            print("failed to fetch Timetables when deleting all Timetables")
            abort()
        }
    }
    
    
    func deleteAllClasses(managedObjectContext: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<Classes>
        if #available(iOS 10.0, *) {
            fetchRequest = Classes.fetchRequest()
        } else {
            fetchRequest = NSFetchRequest(entityName: "Classes")
        }
        do {
            let classesObjects = try managedObjectContext.fetch(fetchRequest)
            for object in classesObjects {
                managedObjectContext.delete(object)
            }
        } catch let error {
            print(error.localizedDescription)
            print("failed to fetch Classes when deleting all Classes")
            abort()
        }
    }
    
    
    func deleteAllCourseTimes(managedObjectContext: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<CourseTimes>
        if #available(iOS 10.0, *) {
            fetchRequest = CourseTimes.fetchRequest()
        } else {
            fetchRequest = NSFetchRequest(entityName: "CourseTimes")
        }
        do {
            let courseTimesObjects = try managedObjectContext.fetch(fetchRequest)
            for object in courseTimesObjects {
                managedObjectContext.delete(object)
            }
        } catch let error {
            print(error.localizedDescription)
            print("failed to fetch CourseTimes when deleting all CourseTimes")
        }
    }
    
    
    func deleteAllEvents(managedObjectContext: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<Events>
        if #available(iOS 10.0, *) {
        fetchRequest = Events.fetchRequest()
        } else {
        fetchRequest = NSFetchRequest(entityName: "Events")
        }
        do {
            let eventsObjects = try managedObjectContext.fetch(fetchRequest)
            for object in eventsObjects {
                EventStore.shared.deleteEventWith(key: object)
                managedObjectContext.delete(object)
            }
        } catch let error {
            print(error.localizedDescription)
            print("failed to fetch Events when deleting all Events")
        }
    }
}
