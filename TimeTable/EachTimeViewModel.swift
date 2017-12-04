//
//  EachTimeViewModel.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2017/03/16.
//  Copyright © 2017 Shuhei Fujita. All rights reserved.
//

import Foundation
import CoreData

class EachTimeViewModel {
    
    
    static let shared: EachTimeViewModel = {
        let instance = EachTimeViewModel()
        return instance
    }()
    
    let defaultStack = CoreDataStack.shared
    
    func saveTimesAt(period: Int, startTime: Date, endTime: Date, courseTimes: [CourseTimes]) {
        
        print("saveCourseTimesAtPeriod")
        for courseTime in courseTimes {
            if courseTime.index.intValue == (period - 1) * 2 {
                courseTime.setValue(startTime, forKey: "time")
            } else if courseTime.index.intValue == (period - 1) * 2 + 1 {
                courseTime.setValue(endTime, forKey: "time")
            }
        }
        defaultStack.saveContext()
    }
    
    
    func startTimeAt(period: Int, courseTimes: [CourseTimes]) -> Date {
        
        return courseTimes[(period - 1) * 2].time
    }
    
    
    func endTimeAt(period: Int, courseTimes: [CourseTimes]) -> Date {
        
        return courseTimes[(period - 1) * 2 + 1].time
    }
}
