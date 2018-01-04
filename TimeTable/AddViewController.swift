//
//  AddTableViewController.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/03/10.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit
import CoreData
import Eureka

class AddViewController: FormViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let model = AddViewModel.shared
    var fetchedResultsController: NSFetchedResultsController<Timetables>?
    var daySelected: Int = 0
    var classesSelected: Int = 5
    var scheduleTitle: String = ""
    let numClasses: [Int] = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    
    @IBAction func doneButtonPushed(_ sender: UIBarButtonItem) {
        if scheduleTitle.isEmpty {
            showAlert()
        } else {
            model.saveNewTimetable(timetableName: scheduleTitle, numberOfDays: daySelected, numberOfClasses: classesSelected, frc: fetchedResultsController!)
            performSegue(withIdentifier: "addCompleted", sender: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section(NSLocalizedString("ScheduleHeader", comment: ""))
            <<< TextRow() { row in
                row.title = NSLocalizedString("ScheduleTitle", comment: "")
                row.placeholder = NSLocalizedString("EnterTitle", comment: "")
                } .onChange { row in
                    if row.value == nil {
                        self.scheduleTitle = ""
                    } else {
                        self.scheduleTitle = row.value!
                    }
            }
        
            <<< PickerInlineRow<String> { row in
                row.title = "Class Days"
                row.options = appDelegate.days
                row.value = row.options[daySelected]
                } .onChange { row in
                    self.daySelected = self.appDelegate.days.index(of: row.value!)!
                }
        
            <<< PickerInlineRow<Int> { row in
                row.title = "Periods"
                row.options = numClasses
                row.value = classesSelected
                } . onChange { row in
                    self.classesSelected = row.value!
                }
        
        animateScroll = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert() {
        let title = "Notice"
        let message = NSLocalizedString("TitleEmpty", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
