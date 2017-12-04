//
//  EventStore.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2016/03/10.
//  Copyright © 2016年 Shuhei Fujita. All rights reserved.
//

import UIKit
import EventKit

class EventStore: EKEventStore {

    static let shared: EventStore = {
        let instance = EventStore()
        return instance
    }()
    
    var calendarAuthorization: Bool = false
    
    func checkAuthorizationStatus() {
        
        let status = EKEventStore.authorizationStatus(for: .event)
        switch(status) {
        case EKAuthorizationStatus.notDetermined:
            //This happens on first-run
            return requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            calendarAuthorization = true
        case EKAuthorizationStatus.restricted, .denied:
            //we need to help them to give us permission
            calendarAuthorization = false
        }
    }
    
    
    func requestAccessToCalendar () {
        
        requestAccess(to: .event, completion: {
            granted, error in
            if granted {
                //Ensure that UI refreshes happen back on the main thread
                DispatchQueue.main.async(execute: {
                    self.calendarAuthorization = true
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.calendarAuthorization = false
                })
            }
        })
    }
    
    
    func saveClass (title: String, location: String, date: Date, startHours: Int, startMinutes: Int, endHours: Int, endMinutes: Int, gregorianCalendar: Calendar) -> String {
        
        let event = EKEvent(eventStore: self)
        event.title = title
        event.location = location
        event.notes = "Saved by TimeTable"
        event.startDate = (gregorianCalendar as NSCalendar).date(bySettingHour: startHours, minute: startMinutes, second: 00, of: date, options: [])!
        event.endDate = (gregorianCalendar as NSCalendar).date(bySettingHour: endHours, minute: endMinutes, second: 00, of: date, options: [])!
        event.calendar = self.defaultCalendarForNewEvents
        saveEvent(event: event)
        return event.eventIdentifier
    }
    
    
    /**
     fetchEventsFromCalendar
     Eventsエンティティに該当するEKEventを配列で返す
     CalendarSettingVCで使用。
     - parameter eventsObjects: [AnyObject]
     
     - returns: [EKEvents?]
     */
    func fetchEventsFromCalendar (eventsObjects: [AnyObject]) -> [EKEvent?] {
        
        var calendarEventsArray: [EKEvent?] = []
        for eventsObject in eventsObjects {
            calendarEventsArray.append(event(withIdentifier: (eventsObject as! Events).eventIdentifier))
        }
        return calendarEventsArray
    }
    
    
    func fetchEvent (eventsObject: Events) -> EKEvent? {
        
        return event(withIdentifier: eventsObject.eventIdentifier)
    }
    
    
    /**
     deleteEvent
     渡された一つのEKEventを削除する。
     CalendarSettingVCで使用。
     
     - parameter event: EKEvent
     */
    func deleteEvent (event: EKEvent?) {

        if event != nil {
            do {
                try self.remove(event!, span: .thisEvent)
                print("deleteEvent")
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
    func deleteEventWith(key: Events) {
        
        deleteEvent(event: fetchEvent(eventsObject: key))
    }
    
    /**
     deleteAllEvents
     EKEventの配列で渡されたイベントをすべて削除する。
     DetailVCで使用。
     
     - parameter eventsArray: [EKEvent?]
     */
    func deleteAllEvents (eventsArray: [EKEvent?]) {
        
        print("deleteAllEvents")
        for event in eventsArray {
            if event != nil {
                deleteEvent(event: event as EKEvent!)
            }
        }
    }
    
    
    func saveEvent (event: EKEvent) {
        
        do {
            try self.save(event, span: EKSpan.futureEvents)
            print("saveEvent")
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
