//
//  CalendarSettingViewModel.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2017/03/16.
//  Copyright © 2017 Shuhei Fujita. All rights reserved.
//

import Foundation
import CoreData

class CalendarSettingViewModel {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaultStack = CoreDataStack.shared
    let eventStore = EventStore.shared
    
    static let shared: CalendarSettingViewModel = {
        let instance = CalendarSettingViewModel()
        return instance
    }()
    
    func calendarAuthorized() -> Bool {
        
        eventStore.checkAuthorizationStatus()
        return eventStore.calendarAuthorization
    }
    
    func isDateValid(startDate: Date, endDate: Date) -> Bool {
        if (startDate != (startDate as NSDate).earlierDate(endDate)) {
            return false
        } else {
            return true
        }
    }
    
    func isTimeValid(endTime: Date) -> Bool {
        let endOfDay = (appDelegate.gregorianCalendar as NSCalendar).date(era: 1, year: 1970, month: 1, day: 2, hour: 0, minute: 0, second: 0, nanosecond: 0)!
        if((endTime as NSDate).earlierDate(endOfDay) == endOfDay) {
                return false
        } else {
            return true
        }
    }
    
    func updateCalendarSync (timetable: Timetables, startDate: Date, endDate: Date, courseTimes: [CourseTimes]) {
        let classes = fetchClasses(timetable: timetable)
        let oldStartDate = timetable.startDate
        let oldEndDate = timetable.endDate
        print("startDate = \(startDate)")
        print("endDate = \(endDate)")
        //先に新しく保存する
        if isEarlierOnDayUnit(comparedDate: startDate, baseDate: oldStartDate) {
            print("startDateからoldStartDateの1日前まで保存")
            let date = (appDelegate.gregorianCalendar as NSCalendar).date(byAdding: .day, value: -1, to: oldStartDate as Date, options: [])!
            saveEventsDuringTerm(startDate: startDate, endDate: date, timetable: timetable, courseTimes: courseTimes)
        }
        if isEarlierOnDayUnit(comparedDate: oldEndDate, baseDate: endDate) {
            print("oldEndDateの翌日からendDateまで保存")
            let date = (appDelegate.gregorianCalendar as NSCalendar).date(byAdding: .day, value: 1, to: oldEndDate as Date, options: [])!
            saveEventsDuringTerm(startDate: date, endDate: endDate, timetable: timetable, courseTimes: courseTimes)
        }
        //次に削除する
        if isEarlierOnDayUnit(comparedDate: oldStartDate, baseDate: startDate) {
            print("oldStartDateからstartDateの1日前まで削除")
            let date = (appDelegate.gregorianCalendar as NSCalendar).date(byAdding: .day, value: -1, to: startDate, options: [])!
            deleteEventsDuringTerm(startDate: oldStartDate as Date, endDate: date, classes: classes)
        }
        if isEarlierOnDayUnit(comparedDate: endDate, baseDate: oldEndDate) {
            print("endDateの翌日からoldEndDateまで削除")
            let date = (appDelegate.gregorianCalendar as NSCalendar).date(byAdding: .day, value: 1, to: endDate, options: [])!
            deleteEventsDuringTerm(startDate: date, endDate: oldEndDate as Date, classes: classes)
        }
        print("updateCalendarSync")
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
    
    // MARK - EventStore & Events Entity
    /**
     saveEventsDuringTerm
     startDateからendDateの期間、ClassesObjectsをカレンダー・Eventsエンティティに保存する
     
     - parameter startDate: NSDate
     - parameter endDate:   NSDate
     */
    func saveEventsDuringTerm (startDate: Date, endDate: Date, timetable: Timetables, courseTimes: [CourseTimes]) {
        print("saveEventsDuringTerm")
        let classes = fetchClasses(timetable: timetable)
        let numberOfDays = timetable.numberOfDays.intValue + 5
        for aClass in classes {
            let indexPath = IndexPath(row: aClass.indexPath.intValue, section: 0)
            let period: Int = indexPath.row / (numberOfDays + 1)
            let classWeekday: Int = indexPath.row % (numberOfDays + 1) + 1
            let startTime = startTimeAtPeriod(period: period, courseTimes: courseTimes)
            let endTime = endTimeAtPeriod(period: period, courseTimes: courseTimes)
            let startHours: Int = (appDelegate.gregorianCalendar as NSCalendar).component(.hour, from: startTime)
            let startMinutes: Int = (appDelegate.gregorianCalendar as NSCalendar).component(.minute, from: startTime)
            let endHours: Int = (appDelegate.gregorianCalendar as NSCalendar).component(.hour, from: endTime)
            let endMinutes: Int = (appDelegate.gregorianCalendar as NSCalendar).component(.minute, from: endTime)
            var classDate = firstClassDate(baseDate: startDate, weekday: classWeekday)
            while (isBetweenRange(startDate: startDate, endDate: endDate, date: classDate)) {
                let title = aClass.lessonName
                print("title = \(title), date = \(classDate)")
                let location = aClass.roomName
                let identifier = eventStore.saveClass(title: title, location: location, date: classDate, startHours: startHours, startMinutes: startMinutes, endHours: endHours, endMinutes: endMinutes, gregorianCalendar: appDelegate.gregorianCalendar)
                let newEventsEntitiy = NSEntityDescription.insertNewObject(forEntityName: "Events", into: defaultStack.managedObjectContext)
                newEventsEntitiy.setValue(aClass, forKey: "classes")
                newEventsEntitiy.setValue(identifier, forKey: "eventIdentifier")
                defaultStack.saveContext()
                //保存終了後、一週間後に設定
                classDate = (appDelegate.gregorianCalendar as NSCalendar).date(byAdding: .day, value: 7, to: classDate, options: [])!
            }
        }
    }
    
    /**
     firstClassDate
     学期開始日baseDateから最初の授業日を返す
     CalendarSettingVC,DetailVCで使用
     
     - parameter baseDate: NSDate
     - parameter weekday:  Int
     
     - returns: NSDate
     */
    func firstClassDate (baseDate: Date, weekday: Int) -> Date {
        let baseWeekday: Int = (appDelegate.gregorianCalendar as NSCalendar).component(.weekday, from: baseDate)
        var addingDay: Int = weekday - baseWeekday
        if(addingDay < 0) {
            addingDay = addingDay + 7
        }
        return (appDelegate.gregorianCalendar as NSCalendar).date(byAdding: .day, value: addingDay, to: baseDate, options: [])!
    }
    
    /**
     startTimeAtPeriod
     TimeTableVC、TableEditVC,EachTimeVC、CalendarSettingVCで使用。
     
     - parameter period: Int 何限目か
     - parameter CourseTimesObjects: [AnyObject]
     
     - return: NSDate
     */
    func startTimeAtPeriod (period: Int, courseTimes: [CourseTimes]) -> Date {
        let startTime: Date = courseTimes[(period - 1) * 2].time as Date
        return startTime
    }
    
    /**
     endTimeAtPeriod
     TimeTableVC、TableEditVC,EachTimeVC、CalendarSettingVCで使用。
     
     - parameter period: Int 何限目か
     - parameter CourseTimesObjects: [AnyObject]
     
     - return: NSDate
     */
    func endTimeAtPeriod (period: Int, courseTimes: [CourseTimes]) -> Date {
        let endTime: Date = courseTimes[(period - 1) * 2 + 1].time as Date
        return endTime
    }
    
    /**
     deleteEventsDuringTerm
     startDateからendDateまでの期間にあるClassesObjectsに関連付けられたEventsエンティティ、EKEventを削除する
     
     - parameter startDate: NSDate
     - parameter endDate:   NSDate
     */
    func deleteEventsDuringTerm (startDate: Date, endDate: Date, classes: [Classes]) {
        print("deleteEventsDuringTerm")
        for aClass in classes {
            let events = associatedEvents(aClass: aClass)
            for event in events {
                let calendarEvent = eventStore.event(withIdentifier: event.eventIdentifier)
                if calendarEvent == nil {
                    defaultStack.managedObjectContext.delete(event)
                    defaultStack.saveContext()
                    continue
                }
                if isBetweenRange(startDate: startDate, endDate: endDate, date: calendarEvent!.startDate) {
                    defaultStack.managedObjectContext.delete(event)
                    defaultStack.saveContext()
                    eventStore.deleteEvent(event: calendarEvent!)
                }
            }
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
     deleteAllEvents
     ClassesObjectsを元に、関連付けられたEventStoreのEvent、Eventsエンティティをすべて削除する
     
     */
    func deleteAllEvents (timetable: Timetables) {
        print("deleteAllEvents")
        let classes = fetchClasses(timetable: timetable)
        for aClass in classes {
            let eventsObjects = associatedEvents(aClass: aClass)
            let eventsArray = eventStore.fetchEventsFromCalendar(eventsObjects: eventsObjects)
            eventStore.deleteAllEvents(eventsArray: eventsArray)
            for eventsObject in eventsObjects {
                defaultStack.managedObjectContext.delete(eventsObject as NSManagedObject)
            }
            print("saveContext")
            defaultStack.saveContext()
        }
    }
    
    func saveDates(startDate: Date, endDate: Date, timetable: NSManagedObject) {
        print("saveDates")
        timetable.setValue(startDate, forKey: "startDate")
        timetable.setValue(endDate, forKey: "endDate")
        defaultStack.saveContext()
    }
    
    func deleteDates(timetable: Timetables) {
        
        timetable.setValue(nil, forKey: "startDate")
        timetable.setValue(nil, forKey: "endDate")
        defaultStack.saveContext()
    }
    
    func associatedEvents (aClass: Classes) -> [Events] {
        let eventsFetchRequest: NSFetchRequest<Events>
        if #available(iOS 10.0, *) {
            eventsFetchRequest = Events.fetchRequest()
        } else {
            eventsFetchRequest = NSFetchRequest(entityName: "Events")
        }
        let eventsPredicate = NSPredicate(format: "classes = %@", aClass)
        eventsFetchRequest.predicate = eventsPredicate
        var eventsObjects: [Events] = []
        do {
            eventsObjects = try defaultStack.managedObjectContext.fetch(eventsFetchRequest)
        } catch let error {
            print("failed to fetch Events")
            print(error.localizedDescription)
        }
        return eventsObjects
    }
    
    func fetchClasses (timetable: Timetables) -> [Classes] {
        print("fetchClasses/CalendarSettingViewModel")
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
        var classes: [Classes] = []
        do {
            classes = try defaultStack.managedObjectContext.fetch(fetchRequest)
        } catch let error {
            print("failed to fetch associated Classes")
            print(error.localizedDescription)
        }
        return classes
    }
}
