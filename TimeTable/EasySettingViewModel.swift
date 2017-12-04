//
//  EasySettingViewModel.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2017/03/16.
//  Copyright © 2017 Shuhei Fujita. All rights reserved.
//

import Foundation
import CoreData

class EasySettingViewModel {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaultStack = CoreDataStack.shared
    
    static let shared: EasySettingViewModel = {
        let instance = EasySettingViewModel()
        return instance
    }()
    
    func saveCourseTimes(numberOfClasses: Int, startTime: Date, breakIndex: Int, classLength: Int, breakLength: Int, intervalLength: Int, courseTimes: [CourseTimes], timetable: Timetables) {
        
        if !courseTimes.isEmpty {
            print("既存のcourseTimesObjectsを削除")
            for courseTime in courseTimes {
                defaultStack.managedObjectContext.delete(courseTime)
            }
        }
        
        var insertTime: Date?
        for i in 0 ..< numberOfClasses * 2 {
            if(i == 0) {
                insertTime = startTime
            } else if(i % 2 == 1) {
                //終了時間
                insertTime = (appDelegate.gregorianCalendar as NSCalendar).date(byAdding: .minute, value: classLength, to: insertTime!, options: [])
            } else {
                //開始時間
                if(i / 2 == breakIndex) {
                    insertTime = (appDelegate.gregorianCalendar as NSCalendar).date(byAdding: .minute, value: breakLength, to: insertTime!, options: [])
                } else {
                    insertTime = (appDelegate.gregorianCalendar as NSCalendar).date(byAdding: .minute, value: intervalLength, to: insertTime!, options: [])
                }
            }
            let courseTime: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: "CourseTimes", into: defaultStack.managedObjectContext)
            courseTime.setValue(timetable, forKey: "timetables")
            courseTime.setValue(insertTime!, forKey: "time")
            courseTime.setValue(i, forKey: "index")
        }
        print("saveWholeCourseTimes")
        defaultStack.saveContext()
    }
    
    
    func setTimeIsSet(timetable: Timetables) {
        
        timetable.setValue(true, forKey: "timeIsSet")
        defaultStack.saveContext()
    }
    
    
    func fetchCourseTimes(timetable: Timetables?) -> [CourseTimes] {
        
        var courseTimes: [CourseTimes] = []
        if timetable == nil {
            return courseTimes
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
            do {
                courseTimes = try defaultStack.managedObjectContext.fetch(fetchRequest)
            } catch {
                print("failed to fetch CourseTimes")
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            return courseTimes
        }
        
    }
}
