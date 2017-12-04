//
//  Classes.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/03/26.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import Foundation
import CoreData

class Classes: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Classes> {
        return NSFetchRequest(entityName: "Classes")
    }
    
    @NSManaged var lessonName: String
    @NSManaged var teacherName: String
    @NSManaged var roomName: String
    @NSManaged var memo: String
    @NSManaged var indexPath: NSNumber
    @NSManaged var color: NSNumber
    @NSManaged var timetables: NSManagedObject
    @NSManaged var events: NSSet

}
