//
//  TimeTableViewModel.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2017/03/15.
//  Copyright © 2017 Shuhei Fujita. All rights reserved.
//

import Foundation
import CoreData

class TimeTableViewModel {
    
    let defaultStack = CoreDataStack.shared
    
    static let shared: TimeTableViewModel = {
        let instance = TimeTableViewModel()
        return instance
    }()
    
    func fetchTimetableWith(uuid: String?) -> Timetables? {
        print("fetchTimetableWith UUID")
        if uuid == nil {
            return nil
        } else if uuid!.isEmpty {
            return nil
        }
        print(uuid!)
        let fetchRequest: NSFetchRequest<Timetables>
        if #available(iOS 10.0, *) {
            fetchRequest = Timetables.fetchRequest()
        } else {
            fetchRequest = NSFetchRequest(entityName: "Timetables")
        }
        let predicate = NSPredicate(format: "uniqueIdentifier = %@", uuid!)
        fetchRequest.predicate = predicate
        do {
            let timetableObjects = try defaultStack.managedObjectContext.fetch(fetchRequest) as [Timetables]
            if !timetableObjects.isEmpty {
                return timetableObjects[0]
            } else {
                return nil
            }
        } catch let error {
            print(error.localizedDescription)
            print("failed to fetchTimetablesWith UUID")
            return nil
        }
    }
    
    func fetchTimetableWith(timetableName: String?) -> Timetables? {
        if timetableName == nil {
            print("timetableName is nil./TimeTableViewModel fetchTimetableWith timetable")
            return nil
        }
        if timetableName!.isEmpty {
            print("timetableName is empty./TimeTableViewModel fetchTimetableWith timetable")
            return nil
        }
        let fetchRequest: NSFetchRequest<Timetables>
        if #available(iOS 10.0, *) {
            fetchRequest = Timetables.fetchRequest()
        } else {
            fetchRequest = NSFetchRequest(entityName: "Timetables")
        }
        let predicate = NSPredicate(format: "timetableName = %@", timetableName!)
        fetchRequest.predicate = predicate
        do {
            let timetableObjects = try defaultStack.managedObjectContext.fetch(fetchRequest)
            if !timetableObjects.isEmpty {
                return timetableObjects[0]
            } else {
                return nil
            }
        } catch let error {
            print(error.localizedDescription)
            print("failed to fetchTimetablesWithName")
            abort()
        }
    }
    
    
    func fetchClasses(timetable: Timetables?) -> [Classes] {
        print("fetchClasses/TimeTableViewModel")
        if timetable == nil {
            return []
        } else {
            let fetchRequest: NSFetchRequest<Classes>
            if #available(iOS 10.0, *) {
                fetchRequest = Classes.fetchRequest()
            } else {
                fetchRequest = NSFetchRequest(entityName: "Classes")
            }
            let predicate = NSPredicate(format: "timetables = %@", timetable!)
            fetchRequest.predicate = predicate
            let classesSort = NSSortDescriptor(key: "indexPath", ascending: true)
            fetchRequest.sortDescriptors = [classesSort]
            var classes: [Classes] = []
            do {
                classes = try defaultStack.managedObjectContext.fetch(fetchRequest)
                return classes
            } catch let error {
                print("failed to fetch associated Classes")
                print(error.localizedDescription)
            }
            return classes
        }
    }
    
    func fetchCourseTimes(timetable: Timetables?) -> [CourseTimes] {
        print("fetchCourseTimes/TimeTableViewModel")
        if timetable == nil {
            return []
        } else {
            let fetchRequest: NSFetchRequest<CourseTimes>
            if #available(iOS 10.0, *) {
                fetchRequest = CourseTimes.fetchRequest()
            } else {
                fetchRequest = NSFetchRequest(entityName: "CourseTimes")
            }
            let predicate = NSPredicate(format: "timetables = %@", timetable!)
            fetchRequest.predicate = predicate
            let indexDescriptor = NSSortDescriptor(key: "index", ascending: true)
            fetchRequest.sortDescriptors = [indexDescriptor]
            var courseTimes: [CourseTimes] = []
            do {
                print("fetch courseTimes")
                courseTimes = try defaultStack.managedObjectContext.fetch(fetchRequest)
            } catch {
                print("failed to fetch CourseTimes")
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            return courseTimes
        }
    }
    
    func startTime(period: Int, courseTimes: [CourseTimes]) -> Date {
        let startTime: Date = courseTimes[(period - 1) * 2].time as Date
        return startTime
    }
    
    func endTime(period: Int, courseTimes: [CourseTimes]) -> Date {
        let endTime: Date = courseTimes[(period - 1) * 2 + 1].time as Date
        return endTime
    }
    
    /**
     weekDays
     曜日を取得しTimeTable内のIndexPathに合うようにして返す
     - parameter now: NSDate
     
     - returns: Int
     */
    func weekDays(now: Date) -> Int {
        let calender = Calendar(identifier: Calendar.Identifier.gregorian)
        let dateComponents = (calender as NSCalendar).components(.weekday, from: now)//as NSDateComponents
        //dateComponents.weekday: Int = 1が日曜　７が土曜
        if dateComponents.weekday == 1 {
            return 7
        } else {
            return dateComponents.weekday! - 1
        }
    }
}
