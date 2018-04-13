//
//  DetailColorViewModel.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 4/12/18.
//  Copyright © 2018 Shuhei Fujita. All rights reserved.
//

import Foundation
import CoreData

class DetailColorViewModel {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaultStack = CoreDataStack.shared
    let eventStore = EventStore.shared
    
    static let shared: DetailColorViewModel = {
        let instance = DetailColorViewModel()
        return instance
    }()
    
    func updateColor(color: Int, classEntity: Classes) {
        classEntity.setValue(color, forKey: "color")
        defaultStack.saveContext()
    }
}
