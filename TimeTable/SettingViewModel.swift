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
        let fetchRequest: NSFetchRequest<Timetables> = Timetables.fetchRequest()
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
        let fetchRequest: NSFetchRequest<Classes> = Classes.fetchRequest()
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
        let fetchRequest: NSFetchRequest<CourseTimes> = CourseTimes.fetchRequest()
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
        let fetchRequest: NSFetchRequest<Events> = Events.fetchRequest()
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
