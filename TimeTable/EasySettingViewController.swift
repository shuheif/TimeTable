//
//  TimeSettingViewController.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/08/13.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit
import CoreData
import Eureka

class EasySettingViewController: FormViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let model = EasySettingViewModel.shared
    var classLengthPickerOpen = false
    var startTimePickerOpen = false
    var endTimePickerOpen = false
    var intervalPickerOpen = false
    var breakPickerOpen = false
    var breakTimePickerOpen = false
    var classLength: Int = 90//min.
    var intervalLength: Int = 15//min.
    var breakLength: Int = 60//min.
    var breakIndex: Int = 2//2限~3限
    var startTime: Date?
    var intervalByDate: Date?
    var breakLengthByDate: Date?
    var classLengthByDate: Date?
    var baseDate: Date?
    var breakOptions: [String] = []
    
    var timetable: Timetables?
    var courseTimes: [CourseTimes]?
    var numberOfClasses: Int?
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func saveButtonPushed(_ sender: UIBarButtonItem) {
        model.saveCourseTimes(numberOfClasses: numberOfClasses!, startTime: startTime!, breakIndex: breakIndex, classLength: classLength, breakLength: breakLength, intervalLength: intervalLength, courseTimes: courseTimes!, timetable: timetable!)
        model.setTimeIsSet(timetable: timetable!)
        performSegue(withIdentifier: "saveToTableEdit", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("EasySettingVCTitle", comment: "授業時間設定")
        self.navigationItem.leftBarButtonItem = saveButton
        
        numberOfClasses = timetable!.numberOfClasses.intValue
        baseDate = (appDelegate.gregorianCalendar as NSCalendar).date(era: 1, year: 1970, month: 1, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0)
        
        startTime = (appDelegate.gregorianCalendar as NSCalendar).date(era: 1, year: 1970, month: 1, day: 1, hour: 8, minute: 45, second: 0, nanosecond: 0)
        
        classLengthByDate = baseDate!.addingTimeInterval(TimeInterval(60 * classLength))
        intervalByDate = baseDate!.addingTimeInterval(TimeInterval(60 * intervalLength))
        breakLengthByDate = baseDate!.addingTimeInterval(TimeInterval(60 * breakLength))
        
        for i in 0...numberOfClasses! {
            if(i == 0) {
                breakOptions.append(NSLocalizedString("NoLunchbreak", comment: "なし"))
            } else {
                breakOptions.append(i.ordinal + NSLocalizedString("period", comment: "限") + " ~ " + (i + 1).ordinal + NSLocalizedString("period", comment: "限"))
            }
        }
        
        
        form = Section(NSLocalizedString("ClassHours", comment: "Class Hours"))
            <<< CountDownInlineRow() { row in
                row.title = NSLocalizedString("ClassLength", comment: "Class Length")
                row.value = classLengthByDate
                } .onChange { row in
                    self.classLengthByDate = row.value
                    self.classLength = Int(self.classLengthByDate!.timeIntervalSince(self.baseDate!)) / 60
                }
            +++ Section(NSLocalizedString("StartTime", comment: "Start Time"))
            <<< TimeInlineRow() { row in
                row.title = NSLocalizedString("FirstPeriod", comment: "First Period")
                row.value = startTime!
                } .onChange { row in
                    self.startTime = row.value
                }
            +++ Section(NSLocalizedString("Interval", comment: "Interval"))
            <<< CountDownInlineRow() { row in
                row.title = NSLocalizedString("Interval", comment: "Interval")
                row.value = intervalByDate
                } .onChange { row in
                    self.intervalByDate = row.value
                    self.intervalLength = Int(self.intervalByDate!.timeIntervalSince(self.baseDate!)) / 60
                }
            +++ Section(NSLocalizedString("Lunchbreak", comment: "Lunchbreak"))
            <<< PickerInlineRow<String>("LunchbreakTag") { row in
                row.title = NSLocalizedString("Between", comment: "Between")
                row.options = breakOptions
                row.value = row.options[breakIndex]
                } .onChange { row in
                    self.breakIndex = self.breakOptions.index(of: row.value!)!
                }
            <<< CountDownInlineRow() { row in
                row.title = NSLocalizedString("Length", comment: "Length")
                row.value = breakLengthByDate
                } .onChange { row in
                    self.breakLengthByDate = row.value
                    self.breakLength = Int(self.breakLengthByDate!.timeIntervalSince(self.baseDate!)) / 60
                }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GADMasterViewController.shared.setupAd(rootViewController: self)
    }
    
    // MARK: - Navigation
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "saveToTableEdit":
            let controller: TableEditViewController = segue.destination as! TableEditViewController
            controller.courseTimes = model.fetchCourseTimes(timetable: timetable!)
        default:
            return
        }
    }
}
