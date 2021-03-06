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
import NotificationBannerSwift

class CalendarSettingViewController: UITableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaultStack = CoreDataStack.shared
    let model = CalendarSettingViewModel.shared
    let dateComponents = DateComponents()
    var startDate = Date()
    var endDate = Date(timeIntervalSinceNow: 60*60*24*120)//現在から120日後
    var dateFormatter = DateFormatter()
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
        let isSyncOn = timetable!.syncOn
        self.timetable!.setValue(self.syncSwitch.isOn, forKey: "syncOn")
        self.defaultStack.saveContext()
        self.performSegue(withIdentifier: "saveToTEFromCS", sender: self)
        //すでにsaveされているか
        if isSyncOn {
            if syncSwitch.isOn {
                DispatchQueue.global().async {
                    //期間変更を反映
                    print("期間変更を反映")
                    self.model.updateCalendarSync(timetable: self.timetable!, startDate: self.startDate, endDate: self.endDate, courseTimes: self.courseTimes!)
                    //startDate,endDate保存
                    self.model.saveDates(startDate: self.startDate, endDate: self.endDate, timetable: self.timetable!)
                    DispatchQueue.main.async {
                        let title = NSLocalizedString("schedule_has_been_modified", comment: "The schedule has been modified.")
                        let banner = NotificationBanner(title: title)
                        banner.backgroundColor = UIColor.jadeColor()
                        banner.show(bannerPosition: .bottom)
                    }
                }
            } else {
                DispatchQueue.global().async {
                    //イベントを全削除
                    print("イベントを全削除")
                    self.model.deleteAllEvents(timetable: self.timetable!)
                    //startDate,endDate削除
                    self.model.deleteDates(timetable: self.timetable!)
                    DispatchQueue.main.async {
                        let title = NSLocalizedString("Schedule_has_been_deleted", comment: "The schedule has been deleted from Calendar.")
                        let banner = NotificationBanner(title: title)
                        banner.backgroundColor = UIColor.jadeColor()
                        banner.show(bannerPosition: .bottom)
                    }
                }
            }
        } else {
            if syncSwitch.isOn {
                self.timetable!.setValue(self.syncSwitch.isOn, forKey: "syncOn")
                self.defaultStack.saveContext()
                DispatchQueue.global().async {
                    //全保存
                    print("全保存")
                    self.model.saveEventsDuringTerm(startDate: self.startDate, endDate: self.endDate, timetable: self.timetable!, courseTimes: self.courseTimes!)
                    //startDate, endDate保存
                    self.model.saveDates(startDate: self.startDate, endDate: self.endDate, timetable: self.timetable!)
                    DispatchQueue.main.async {
                        let title = NSLocalizedString("Schedule_has_been_saved", comment: "The schedule has been saved to Calendar.")
                        let banner = NotificationBanner(title: title)
                        banner.backgroundColor = UIColor.jadeColor()
                        banner.show(bannerPosition: .bottom)
                    }
                }
            } else {
                //何もせず
                print("何もせず")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startDatePicker.calendar = appDelegate.gregorianCalendar as Calendar
        endDatePicker.calendar = appDelegate.gregorianCalendar as Calendar
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GADMasterViewController.shared.setupAd(rootViewController: self)
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
        switch segue.identifier {
        case "doneToTableEdit":
            let controller: TableEditViewController = segue.destination as! TableEditViewController
            controller.timetable = timetable!
        default:
            return
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
            preferredStyle: UIAlertController.Style.alert)
        
        let settingAction = UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler:
            {(action: UIAlertAction!) -> Void in
                let url = URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(settingAction)
        self.present(alert, animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
