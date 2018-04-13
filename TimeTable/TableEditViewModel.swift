//
//  TableEditViewModel.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2017/03/16.
//  Copyright © 2017 Shuhei Fujita. All rights reserved.
//

import Foundation
import CoreData

class TableEditViewModel {
    
    let defaultStack = CoreDataStack.shared
    
    static let shared: TableEditViewModel = {
        let instance = TableEditViewModel()
        return instance
    }()
    
    func saveTimetables(timetable: Timetables, timetableName: String, showTime: Bool) {
        print("saveTimetables")
        timetable.setValue(timetableName, forKey: "timetableName")
        timetable.setValue(showTime, forKey: "showTime")
        defaultStack.saveContext()
    }
    
    func startTime(period: Int, courseTimes: [CourseTimes]) -> Date {
        let startTime: Date = courseTimes[(period - 1) * 2].time as Date
        return startTime
    }
    
    func endTime(period: Int, courseTimes: [CourseTimes]) -> Date {
        let endTime: Date = courseTimes[(period - 1) * 2 + 1].time as Date
        return endTime
    }
    
    func fetchCourseTimes(timetable: Timetables) -> [CourseTimes] {
        print("fetchCourseTimes/TableEditViewModel")
        let fetchRequest: NSFetchRequest<CourseTimes>
        if #available(iOS 10.0, *) {
            fetchRequest = CourseTimes.fetchRequest()
        } else {
            fetchRequest = NSFetchRequest(entityName: "CourseTimes")
        }
        let predicate = NSPredicate(format: "timetables = %@", timetable)
        fetchRequest.predicate = predicate
        let indexDescriptor = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [indexDescriptor]
        var courseTimes:[CourseTimes] = []
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
