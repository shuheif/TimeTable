//
//  EachTimeViewController.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/09/17.
//  Copyright © 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit
import CoreData

class EachTimeViewController: UITableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let model = EachTimeViewModel.shared
    
    var dateFormatter = DateFormatter()
    var startTime: Date?
    var endTime: Date?
    var selectedPeriod: Int?
    var courseTimes: [CourseTimes]?
    
    @IBOutlet weak var startTimeCell: UITableViewCell!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimeCell: UITableViewCell!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    
    @IBAction func saveButtonPushed (_ sender: UIBarButtonItem) {
        model.saveTimesAt(period: selectedPeriod!, startTime: startTime!, endTime: endTime!, courseTimes: courseTimes!)
        performSegue(withIdentifier: "saveToTableEdit", sender: self)
    }
    
    @IBAction func startPickerChanged (_ sender: UIDatePicker) {
        startTime = sender.date
        configureStartTimeCellDetail()
    }
    
    @IBAction func endPickerChanged (_ sender: UIDatePicker) {
        endTime = sender.date
        configureEndTimeCellDetail()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title =  selectedPeriod!.ordinal + NSLocalizedString("period", comment: "限")
        dateFormatter.calendar = appDelegate.gregorianCalendar as Calendar!
        dateFormatter.timeStyle = DateFormatter.Style.short
        startTimePicker.calendar = appDelegate.gregorianCalendar as Calendar!
        endTimePicker.calendar = appDelegate.gregorianCalendar as Calendar!
        startTime = model.startTimeAt(period: selectedPeriod!, courseTimes: courseTimes!)
        endTime = model.endTimeAt(period: selectedPeriod!, courseTimes: courseTimes!)
        startTimePicker.date = startTime!
        endTimePicker.date = endTime!
        configureStartTimeCellDetail()
        configureEndTimeCellDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GADMasterViewController.shared.setupAd(rootViewController: self)
    }

    func configureStartTimeCellDetail() {
        startTimeCell.detailTextLabel?.text = dateFormatter.string(from: self.startTime!)
    }
    
    func configureEndTimeCellDetail() {
        endTimeCell.detailTextLabel?.text = dateFormatter.string(from: self.endTime!)
    }
    
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveToTableEdit" {
            let controller = segue.destination as! TableEditViewController
            controller.courseTimes = courseTimes!
        }
    }
}
