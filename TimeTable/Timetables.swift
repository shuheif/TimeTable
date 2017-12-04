//
//  Timetables.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/03/26.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import Foundation
import CoreData

class Timetables: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Timetables> {
        return NSFetchRequest(entityName: "Timetables")
    }

    @NSManaged var timetableName: String
    @NSManaged var uniqueIdentifier: String
    @NSManaged var numberOfDays: NSNumber
    @NSManaged var numberOfClasses: NSNumber
    @NSManaged var archiveOrder: NSNumber
    @NSManaged var showTime: Bool
    @NSManaged var syncOn: Bool
    @NSManaged var timeIsSet: Bool
    @NSManaged var startDate: Date
    @NSManaged var endDate: Date
    @NSManaged var classes: NSSet

}
