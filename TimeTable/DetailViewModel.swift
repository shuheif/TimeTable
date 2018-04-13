//
//  DetailViewModel.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2017/03/16.
//  Copyright © 2017 Shuhei Fujita. All rights reserved.
//

import Foundation
import CoreData

class DetailViewModel {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaultStack = CoreDataStack.shared
    let eventStore = EventStore.shared
    
    static let shared: DetailViewModel = {
        let instance = DetailViewModel()
        return instance
    }()
    
    func saveAClass(aClass: Classes?, timetable: Timetables, lessonName: String?, teacherName: String?, roomName: String?, memo: String?, indexPath: IndexPath) -> Classes {
        var aClassEntitiy: NSManagedObject? = aClass
        if aClassEntitiy == nil {
            //Create new Classes Entity
            aClassEntitiy = NSEntityDescription.insertNewObject(forEntityName: "Classes", into: defaultStack.managedObjectContext)
        }
        aClassEntitiy!.setValue(timetable, forKey: "timetables")
        aClassEntitiy!.setValue(lessonName, forKey: "lessonName")
        aClassEntitiy!.setValue(teacherName, forKey: "teacherName")
        aClassEntitiy!.setValue(roomName, forKey: "roomName")
        aClassEntitiy!.setValue(memo, forKey: "memo")
        aClassEntitiy!.setValue(indexPath.row, forKey: "indexPath")
        print("saveAClass")
        defaultStack.saveContext()
        return aClassEntitiy! as! Classes
    }
    
    /**
     saveEventDuringTerm
     eventStoreとEventsエンティティにClassesObjectを保存。CalendarSettingVCから一部をコピペして作成
     
     - parameter startDate: NSDate
     - parameter endDate:   NSDate
     */
    func saveEventDuringTerm(startDate: Date, endDate: Date, aClass: Classes, timetable: Timetables, indexPath: IndexPath, courseTimes: [CourseTimes], title: String, location: String) {
        print("saveEventDuringTerm")
        let numberOfDays = timetable.numberOfDays.intValue + 5
        let period: Int =  indexPath.row / (numberOfDays + 1)
        let classWeekday: Int = indexPath.row % (numberOfDays + 1) + 1
        let startTime: Date = courseTimes[(period - 1) * 2].time as Date
        let endTime: Date = courseTimes[(period - 1) * 2 + 1].time as Date
        let startHours: Int = (appDelegate.gregorianCalendar as NSCalendar).component(.hour, from: startTime)
        let startMinutes: Int = (appDelegate.gregorianCalendar as NSCalendar).component(.minute, from: startTime)
        let endHours: Int = (appDelegate.gregorianCalendar as NSCalendar).component(.hour, from: endTime)
        let endMinutes: Int = (appDelegate.gregorianCalendar as NSCalendar).component(.minute, from: endTime)
        let baseWeekday: Int = (appDelegate.gregorianCalendar as NSCalendar).component(.weekday, from: startDate)
        var addingDay: Int = classWeekday - baseWeekday
        if(addingDay < 0) {
            addingDay = addingDay + 7
        }
        var classDate = (appDelegate.gregorianCalendar as NSCalendar).date(byAdding: .day, value: addingDay, to: startDate, options: [])!
        while (isBetweenRange(startDate: startDate, endDate: endDate, date: classDate)) {
            let identifier = eventStore.saveClass(title: title, location: location, date: classDate, startHours: startHours, startMinutes: startMinutes, endHours: endHours, endMinutes: endMinutes, gregorianCalendar: appDelegate.gregorianCalendar)
            let newEventsEntitiy = NSEntityDescription.insertNewObject(forEntityName: "Events", into: defaultStack.managedObjectContext)
            newEventsEntitiy.setValue(aClass, forKey: "classes")
            newEventsEntitiy.setValue(identifier, forKey: "eventIdentifier")
            defaultStack.saveContext()
            //保存終了後、一週間後に設定
            classDate = (appDelegate.gregorianCalendar as NSCalendar).date(byAdding: .day, value: 7, to: classDate, options: [])!
        }
    }
    
    /**
     isBetweenRange
     dateがstartDateとendDateの範囲内にあるか、日付までの計算で値を返す
     CalendarSettingVC,DetailVCで使用。
     - parameter startDate: NSDate
     - parameter endDate:   NSDate
     - parameter date: NSDate
     
     - returns: Bool
     */
    func isBetweenRange (startDate: Date, endDate: Date, date: Date) -> Bool {
        if isEarlierOnDayUnit(comparedDate: date, baseDate: startDate) {
            return false
        } else if isEarlierOnDayUnit(comparedDate: endDate, baseDate: date) {
            return false
        } else {
            return true
        }
    }
    
    /**
     isEarlierOnDayUnit
     comparedDateがbaseDateより早かったらture
     
     - parameter comparedDate: NSDate
     - parameter baseDate:     NSDate
     
     - returns: Bool
     */
    func isEarlierOnDayUnit (comparedDate: Date, baseDate: Date) -> Bool {
        var result = false
        if (appDelegate.gregorianCalendar as NSCalendar).compare(comparedDate, to: baseDate, toUnitGranularity: .day) == .orderedAscending {
            result = true
        }
        return result
    }
    
    func editEvents(aClass: Classes) {
        print("editEvents")
        let eventsObjects = associatedEvents(aClass: aClass)
        let eventsArray = eventStore.fetchEventsFromCalendar(eventsObjects: eventsObjects)
        for event in eventsArray {
            if event != nil {
                event!.title = aClass.lessonName
                event!.location = aClass.roomName
                eventStore.saveEvent(event: event!)
            }
        }
    }
    
    /**
     associatedEvents
     ClassObjectに関連付けられたEventsエンティティを返す。
     DetailVC,MenuVCで使用。
     - parameter ClassesObject: NSManagedObject
     
     - returns: [AnyObject]
     */
    func associatedEvents (aClass: Classes) -> [Events] {
        let eventsFetchRequest: NSFetchRequest<Events>
        if #available(iOS 10.0, *) {
            eventsFetchRequest = Events.fetchRequest()
        } else {
            eventsFetchRequest = NSFetchRequest(entityName: "Events")
        }
        let eventsPredicate = NSPredicate(format: "classes = %@", aClass)
        eventsFetchRequest.predicate = eventsPredicate
        var events: [Events] = []
        do {
            events = try defaultStack.managedObjectContext.fetch(eventsFetchRequest)
        } catch let error {
            print("failed to fetch Events")
            print(error.localizedDescription)
        }
        return events
    }
    
    // MARK: - EventStore
    /**
     deleteAssociatedEvents
     ClassesObjectに関連付けられたカレンダーのイベントと、Eventsエンティティをすべて削除する。
     */
    func deleteAssociatedEvents(aClass: Classes?) {
        if aClass != nil {
            let eventsObjects = associatedEvents(aClass: aClass!)
            let eventsArray = eventStore.fetchEventsFromCalendar(eventsObjects: eventsObjects)
            eventStore.deleteAllEvents(eventsArray: eventsArray)
            for eventsObject in eventsObjects {
                defaultStack.managedObjectContext.delete(eventsObject as NSManagedObject)
            }
            defaultStack.saveContext()
        }
        print("deleteAssociatedEvents")
    }
    
    func deleteClasses(aClass: Classes?) {
        
        if aClass != nil {
            defaultStack.managedObjectContext.delete(aClass!)
            defaultStack.saveContext()
        }
    }
    
    func classAt(indexPath: IndexPath, classes: [Classes], timetable: Timetables) -> Classes? {
        for aClass in classes {
            if aClass.indexPath.intValue == indexPath.row {
                return aClass
            }
        }
        return nil
    }
}
