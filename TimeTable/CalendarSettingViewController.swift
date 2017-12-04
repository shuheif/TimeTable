//
//  CalendarSettingViewController.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/08/24.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit
import CoreData
import EventKit
import SVProgressHUD

class CalendarSettingViewController: UITableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaultStack = CoreDataStack.shared
    let model = CalendarSettingViewModel.shared
    
    
    var startDate = Date()
    var endDate = Date(timeIntervalSinceNow: 60*60*24*120)//現在から120日後
    
    var dateFormatter = DateFormatter()
    let dateComponents = DateComponents()
    
    var timetable: Timetables?
    var courseTimes: [CourseTimes]?
    
    
    @IBOutlet weak var syncSwitch: UISwitch!
    @IBOutlet weak var startDateCell: UITableViewCell!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDateCell: UITableViewCell!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    @IBAction func startDatePickerChanged (_ sender: UIDatePicker) {
        
        startDate = sender.date
        startDateCellDetail(startDate)
    }
    
    
    @IBAction func endDatePickerChanged (_ sender: UIDatePicker) {
        
        endDate = sender.date
        endDateCellDetail(endDate)
    }
    
    
    @IBAction func saveButtonPushed (_ sender: UIBarButtonItem) {
        
        //カレンダーへのアクセス権再確認
        if (!model.calendarAuthorized()) {
            showSettingAlert()
            return
        }
        
        //日付の有効性判定
        if !model.isDateValid(startDate: startDate, endDate: endDate) {
            showDateAlert()
            return
        }
        
        if !model.isTimeValid(endTime: courseTimes!.last!.time as Date) {
            showTimeAlert()
            return
        }
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        
        //すでにsaveされているか
        if timetable!.syncOn {
            if syncSwitch.isOn {
                SVProgressHUD.show(withStatus: "Updating")
                
                DispatchQueue.global().async {
                    //期間変更を反映
                    print("期間変更を反映")
                    self.model.updateCalendarSync(timetable: self.timetable!, startDate: self.startDate, endDate: self.endDate, courseTimes: self.courseTimes!)
                    //startDate,endDate保存
                    self.model.saveDates(startDate: self.startDate, endDate: self.endDate, timetable: self.timetable!)
                    DispatchQueue.main.async {
                        SVProgressHUD.showSuccess(withStatus: "Succeeded!")
                        self.timetable!.setValue(self.syncSwitch.isOn, forKey: "syncOn")
                        self.defaultStack.saveContext()
                        
                        self.performSegue(withIdentifier: "saveToTEFromCS", sender: self)
                    }
                }
            } else {
                SVProgressHUD.show(withStatus: "Deleting")
                DispatchQueue.global().async {
                    //イベントを全削除
                    print("イベントを全削除")
                    self.model.deleteAllEvents(timetable: self.timetable!)
                    //startDate,endDate削除
                    self.model.deleteDates(timetable: self.timetable!)
                    DispatchQueue.main.async {
                        SVProgressHUD.showSuccess(withStatus: "Succeeded!")
                        self.timetable!.setValue(self.syncSwitch.isOn, forKey: "syncOn")
                        self.defaultStack.saveContext()
                        self.performSegue(withIdentifier: "saveToTEFromCS", sender: self)
                    }
                }
            }
        } else {
            if syncSwitch.isOn {
                SVProgressHUD.show(withStatus: "Saving")
                DispatchQueue.global().async {
                    //全保存
                    print("全保存")
                    self.model.saveEventsDuringTerm(startDate: self.startDate, endDate: self.endDate, timetable: self.timetable!, courseTimes: self.courseTimes!)
                    //startDate, endDate保存
                    self.model.saveDates(startDate: self.startDate, endDate: self.endDate, timetable: self.timetable!)
                    DispatchQueue.main.async {
                        SVProgressHUD.showSuccess(withStatus: "Succeeded!")
                        self.timetable!.setValue(self.syncSwitch.isOn, forKey: "syncOn")
                        self.defaultStack.saveContext()
                        self.performSegue(withIdentifier: "saveToTEFromCS", sender: self)
                    }
                }
            } else {
                //何もせず
                print("何もせず")
                timetable!.setValue(syncSwitch.isOn, forKey: "syncOn")
                defaultStack.saveContext()
                performSegue(withIdentifier: "saveToTEFromCS", sender: self)
            }
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        startDatePicker.calendar = appDelegate.gregorianCalendar as Calendar!
        endDatePicker.calendar = appDelegate.gregorianCalendar as Calendar!
        dateFormatter.dateStyle = DateFormatter.Style.short
        
        if timetable?.value(forKey: "startDate") != nil {
            startDate = timetable!.startDate
        }
        if timetable?.value(forKey: "endDate") != nil {
            endDate = timetable!.endDate
        }
        
        //Picker初期化
        startDatePicker.date = startDate
        endDatePicker.date = endDate
        //CellDetail初期化
        startDateCellDetail(startDate)
        endDateCellDetail(endDate)
        //syncSwitch初期化
        syncSwitch.isOn = timetable!.syncOn
    }


    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table view
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // MARK: - TableViewCellDetail
    
    func startDateCellDetail(_ startDate: Date) {
    
        startDateCell.detailTextLabel?.text = dateFormatter.string(from: startDate)
    }
    
    
    func endDateCellDetail(_ endDate: Date) {
        
        endDateCell.detailTextLabel?.text = dateFormatter.string(from: endDate)
    }

    
    // MARK: - Navigation

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
       
        if(segue.identifier == "doneToTableEdit") {
            let controller: TableEditViewController = segue.destination as! TableEditViewController
            controller.timetable = timetable!
        }
    }
    
    
    // MARK: - Alert
    
    
    func showTimeAlert () {
        
        let timeAlert = UIAlertController(title: "Error", message: NSLocalizedString("TheEndOfTheTimeMustBeBefore24o'clock", comment: "24時を超える授業時間が設定されているときは、同期できません"), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        timeAlert.addAction(okAction)
        present(timeAlert, animated: true, completion: nil)
    }
    
    
    func showDateAlert () {
        
        let dateAlert = UIAlertController(title: "Error", message: NSLocalizedString("EndDateMustBeAfterStartDate", comment: "学期終了日は開始日より後に設定してください"), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        dateAlert.addAction(okAction)
        present(dateAlert, animated: true, completion: nil)
    }
    
    
    func showSettingAlert () {
        
        let alert = UIAlertController(title: NSLocalizedString("NeedPermission", comment: "This function needs permission to access your calendar data in order to work."),
            message: NSLocalizedString("SettingPrivacy", comment: "Please change status in Setting>Privacy>Calendar"),
            preferredStyle: UIAlertControllerStyle.alert)
        
        let settingAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler:
            {(action: UIAlertAction!) -> Void in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(url!)
                }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(settingAction)
        self.present(alert, animated: true, completion: nil)
    }
}
