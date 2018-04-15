//
//  MenuViewModel.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2017/03/15.
//  Copyright © 2017 Shuhei Fujita. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import EventKit

class MenuViewModel {
    
    static let shared: MenuViewModel = {
        let instance = MenuViewModel()
        return instance
    }()
    
    let userDefaults = UserDefaults.standard
    let defaultStack = CoreDataStack.shared
    let eventStore = EventStore.shared// TODO remove
    
    // Saves seleced Timetables to UserDefaults
    func saveSelectedRow(indexPath: IndexPath, frc: NSFetchedResultsController<Timetables>) {
        
        print("saveSelectedRow")
        let uuid = frc.object(at: indexPath).uniqueIdentifier
        userDefaults.setValue(uuid, forKey: "selectedUUID")
        let success = userDefaults.synchronize()
        if success {
            print("defaults saved")
        }
    }
    
    // Sets archiveOrders when a row is moved
    func setArchiveOrder(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath, frc: NSFetchedResultsController<Timetables>) {
        
        if (sourceIndexPath == destinationIndexPath) {
            return
        } else if (sourceIndexPath.row < destinationIndexPath.row) {
            for i in sourceIndexPath.row+1...destinationIndexPath.row {
                let object = frc.object(at: IndexPath(row: i, section: 0))
                object.setValue(i-1, forKey: "archiveOrder")
            }
        } else {
            for i in destinationIndexPath.row+1...sourceIndexPath.row {
                let object = frc.object(at: IndexPath(row: i, section: 0))
                object.setValue(i+1, forKey: "archiveOrder")
            }
        }
        let movedObject = frc.object(at: sourceIndexPath)
        movedObject.setValue(destinationIndexPath.row, forKey: "archiveOrder")
        defaultStack.saveContext()
    }
    
    // Deletes a Timetables
    func deleteTimetables(targetIndexPath: IndexPath, frc: NSFetchedResultsController<Timetables>) {
        // 残りのarchiveOrderを設定
        let numObject = frc.fetchedObjects!.count
        if targetIndexPath.row < numObject - 1 {
            for i in targetIndexPath.row + 1 ... numObject - 1 {
                frc.object(at: IndexPath(row: i, section: 0)).setValue(i-1, forKey: "archiveOrder")
            }
        }
        let targetTimetable = frc.object(at: targetIndexPath)
        DispatchQueue.global().async {
            self.deleteCourses(timetable: targetTimetable)
        }
        DispatchQueue.global().async {
            self.deleteCourses(timetable: targetTimetable)
        }
        //Timetables削除
        defaultStack.managedObjectContext.delete(targetTimetable)
        defaultStack.saveContext()
        // Resets UserDefaults
        userDefaults.removeObject(forKey: "selectedUUID")
    }
    
    func deleteCourses(timetable: Timetables) {
        //Timetablesに関連付けられたClassesをすべて削除
        let fetchRequest: NSFetchRequest<Classes>
        if #available(iOS 10.0, *) {
            fetchRequest = Classes.fetchRequest()
        } else {
            fetchRequest = NSFetchRequest(entityName: "Classes")
        }
        let predicate = NSPredicate(format: "timetables = %@", timetable)
        fetchRequest.predicate = predicate
        let classesSort = NSSortDescriptor(key: "indexPath", ascending: true)
        fetchRequest.sortDescriptors = [classesSort]
        var relatedClasses: [NSManagedObject] = []
        do {
            relatedClasses = try defaultStack.managedObjectContext.fetch(fetchRequest)
        } catch let error {
            print("failed to fetch associated Classes")
            print(error.localizedDescription)
        }
        for relatedClass in relatedClasses {
            // Associated Events
            let eventsFetchRequest: NSFetchRequest<Events>
            if #available(iOS 10.0, *) {
                eventsFetchRequest = Events.fetchRequest()
            } else {
                eventsFetchRequest = NSFetchRequest(entityName: "Events")
            }
            let eventsPredicate = NSPredicate(format: "classes = %@", relatedClass)
            eventsFetchRequest.predicate = eventsPredicate
            var events: [Events] = []
            do {
                events = try defaultStack.managedObjectContext.fetch(eventsFetchRequest)
            } catch let error {
                print("failed to fetch Events")
                print(error.localizedDescription)
            }
            //Delete events
            for eventsObject in events {
                let event = eventStore.fetchEvent(eventsObject: eventsObject)
                eventStore.deleteEvent(event: event)
                defaultStack.managedObjectContext.delete(eventsObject)
            }
            defaultStack.managedObjectContext.delete(relatedClass)
        }
    }
    
    func deleteCourseTimes(timetable: Timetables) {
        //Timetablesに関連付けられたCourseTimesをすべて削除
        let courseTimesFetchRequest: NSFetchRequest<CourseTimes>
        if #available(iOS 10.0, *) {
            courseTimesFetchRequest = CourseTimes.fetchRequest()
        } else {
            courseTimesFetchRequest = NSFetchRequest(entityName: "CourseTimes")
        }
        let courseTimesPredicate = NSPredicate(format: "timetables = %@", timetable)
        courseTimesFetchRequest.predicate = courseTimesPredicate
        let indexDescriptor = NSSortDescriptor(key: "index", ascending: true)
        courseTimesFetchRequest.sortDescriptors = [indexDescriptor]
        var courseTimes: [NSManagedObject]
        do {
            courseTimes = try defaultStack.managedObjectContext.fetch(courseTimesFetchRequest)
        } catch {
            print("failed to fetch CourseTimes")
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        for courseTime in courseTimes {
            print("delete relatedClassesObject")
            defaultStack.managedObjectContext.delete(courseTime)
        }
    }
    
    // Copies Timetables
    func copyTimetables(targetIndexPath: IndexPath, frc: NSFetchedResultsController<Timetables>) {
        print("MenuVC copyTimetables")
        // reorder Archive order
        let fetchedArray: NSArray = frc.fetchedObjects! as NSArray
        if fetchedArray.count > 1 {
            for i in 0 ... fetchedArray.count - 1 {
                let object = frc.object(at: IndexPath(row: i, section: 0))
                object.setValue(i + 1, forKey: "archiveOrder")
            }
            print("reorder archive order")
            defaultStack.saveContext()
        } else {
            print("no objects")
        }
        
        let baseTimetable = frc.object(at: targetIndexPath)
        print(baseTimetable)
        // Copy Timetables
        let newTimetable = NSEntityDescription.insertNewObject(forEntityName: "Timetables", into: defaultStack.managedObjectContext)
        newTimetable.setValue(String(format: NSLocalizedString("CopyOf", comment: ""), baseTimetable.timetableName), forKey: "timetableName")
        newTimetable.setValue(baseTimetable.numberOfDays, forKey: "numberOfDays")
        newTimetable.setValue(baseTimetable.numberOfClasses, forKey: "numberOfClasses")
        newTimetable.setValue(baseTimetable.showTime, forKey: "showTime")
        newTimetable.setValue(baseTimetable.timeIsSet, forKey: "timeIsSet")
        newTimetable.setValue(NSUUID().uuidString, forKey: "uniqueIdentifier")
        newTimetable.setValue(0, forKey: "archiveOrder")
        print("create new Timetable")
        defaultStack.saveContext()
        // Fetch related Classes
        let fetchRequest: NSFetchRequest<Classes>
        if #available(iOS 10.0, *) {
            fetchRequest = Classes.fetchRequest()
        } else {
            fetchRequest = NSFetchRequest(entityName: "Classes")
        }
        let predicate = NSPredicate(format: "timetables = %@", baseTimetable)
        fetchRequest.predicate = predicate
        let classesSort = NSSortDescriptor(key: "indexPath", ascending: true)
        fetchRequest.sortDescriptors = [classesSort]
        var classes: [Classes] = []
        do {
            print("do fetch classes")
            classes = try defaultStack.managedObjectContext.fetch(fetchRequest)
            print("classes is empty = \(classes.isEmpty)")
        } catch let error {
            print("failed to fetch associated Classes")
            print(error.localizedDescription)
        }
        for aClass in classes {
            let newClasses = NSEntityDescription.insertNewObject(forEntityName: "Classes", into: defaultStack.managedObjectContext)
            newClasses.setValue(newTimetable, forKey: "timetables")
            newClasses.setValue(aClass.lessonName, forKey: "lessonName")
            newClasses.setValue(aClass.teacherName, forKey: "teacherName")
            newClasses.setValue(aClass.roomName, forKey: "roomName")
            newClasses.setValue(aClass.memo, forKey: "memo")
            newClasses.setValue(aClass.color, forKey: "color")
            newClasses.setValue(aClass.indexPath, forKey: "indexPath")
            print("created a new class")
        }
        print("saved new classes")
        defaultStack.saveContext()
        // Copy CourseTimes
        let courseTimesFetchRequest: NSFetchRequest<CourseTimes>
        if #available(iOS 10.0, *) {
            courseTimesFetchRequest = CourseTimes.fetchRequest()
        } else {
            courseTimesFetchRequest = NSFetchRequest(entityName: "CourseTimes")
        }
        let courseTimePredicate = NSPredicate(format: "timetables = %@", baseTimetable)
        courseTimesFetchRequest.predicate = courseTimePredicate
        let indexDescriptor = NSSortDescriptor(key: "index", ascending: true)
        courseTimesFetchRequest.sortDescriptors = [indexDescriptor]
        var courseTimes: [CourseTimes] = []
        do {
            print("do courseTimes fetch")
            courseTimes = try defaultStack.managedObjectContext.fetch(courseTimesFetchRequest)
        } catch {
            print("failed to fetch CourseTimes")
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        for courseTime in courseTimes {
            let newCourseTime: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: "CourseTimes", into: defaultStack.managedObjectContext)
            newCourseTime.setValue(newTimetable, forKey: "timetables")
            newCourseTime.setValue(courseTime.time, forKey: "time")
            newCourseTime.setValue(courseTime.index, forKey: "index")
            print("created a new courseTime")
        }
        print("saved new courseTimes")
        defaultStack.saveContext()
    }
    
    func tagUUID(timetable: Timetables) {
        
        if timetable.uniqueIdentifier.isEmpty {
            timetable.uniqueIdentifier = NSUUID().uuidString
            defaultStack.saveContext()
        }
    }
}
