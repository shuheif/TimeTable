//
//  Events.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2016/04/09.
//  Copyright © 2016年 Shuhei Fujita. All rights reserved.
//

import Foundation
import CoreData

class Events: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Events> {
        return NSFetchRequest(entityName: "Events")
    }
    
    @NSManaged var eventIdentifier: String
    @NSManaged var classes: NSManagedObject
}
