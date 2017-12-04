//
//  CourseTimes.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/09/13.
//  Copyright © 2015年 Shuhei Fujita. All rights reserved.
//

import CoreData

class CourseTimes: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseTimes> {
        return NSFetchRequest(entityName: "CourseTimes")
    }
    
    @NSManaged var index: NSNumber
    @NSManaged var time: Date
    @NSManaged var timetables: NSSet
    
}
