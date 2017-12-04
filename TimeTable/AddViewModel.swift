//
//  AddViewModel.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2017/03/15.
//  Copyright © 2017 Shuhei Fujita. All rights reserved.
//

import Foundation
import CoreData

class AddViewModel {
    
    let defaultStack = CoreDataStack.shared
    
    static let shared: AddViewModel = {
        let instance = AddViewModel()
        return instance
    }()
    
    
    // Saves a new Timetables
    func saveNewTimetable(timetableName: String, numberOfDays: Int, numberOfClasses: Int, frc: NSFetchedResultsController<Timetables>) {
        
        let fetchedArray: NSArray = frc.fetchedObjects! as NSArray
        if fetchedArray.count > 1 {
            for i in 0 ... fetchedArray.count - 1 {
                let object = frc.object(at: IndexPath(row: i, section: 0))
                object.setValue(i + 1, forKey: "archiveOrder")
            }
            defaultStack.saveContext()
        } else {
            print("no objects")
        }
        
        let newTimetables = NSEntityDescription.insertNewObject(forEntityName: "Timetables", into: defaultStack.managedObjectContext)
        newTimetables.setValue(timetableName, forKey: "timetableName")
        newTimetables.setValue(numberOfDays, forKey: "numberOfDays")
        newTimetables.setValue(numberOfClasses, forKey: "numberOfClasses")
        newTimetables.setValue(0, forKey: "archiveOrder")
        newTimetables.setValue(UUID().uuidString, forKey: "uniqueIdentifier")
        defaultStack.saveContext()
        
    }
}
