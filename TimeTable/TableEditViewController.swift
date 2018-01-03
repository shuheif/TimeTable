//
//  TableEditViewController.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/07/06.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit
import CoreData
import Eureka
import GoogleMobileAds

private let timeCellID = "timeCell"

class TableEditViewController: UITableViewController, UITextFieldDelegate, GADInterstitialDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaultStack = CoreDataStack.shared
    let model = TableEditViewModel.shared

    var timetable: Timetables?
    var courseTimes: [CourseTimes]?
    let titleForHeader: [String?] = [NSLocalizedString("EditScheduleTitle", comment: "時間割名編集"), NSLocalizedString("SetClassHours", comment: "授業時間設定"), nil]
    
    var dateFormatter = DateFormatter()
    
    var tableName: String?
    var numberOfClasses: Int?
    var timeIsSet = false
    var showTime = false
    var syncOn = false
    var selectedPeriod: Int?
    
    var interstitial: GADInterstitial!
    
    
    @IBAction func saveButtonPushed(_ sender: UIBarButtonItem) {
        
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        let tableNameCell: TableNameCell =  tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TableNameCell
        
        if tableNameCell.tableNameField.text!.isEmpty {
            tableNameCell.tableNameField.shake()
        } else {
            model.saveTimetables(timetable: timetable!, timetableName: tableNameCell.tableNameField.text!, showTime: showTime)
            performSegue(withIdentifier: "saveToTableFromEdit", sender: self)//２回目に効かない
        }
    }
    
    
    @IBAction func cancelToTableEdit (_ segue: UIStoryboardSegue) {
    }
    
    
    @IBAction func saveToTableEdit (_ segue: UIStoryboardSegue) {
        
        //From EasyVC, EachTimeVC
        timeIsSet = timetable!.timeIsSet
        tableView.reloadData()
    }
    
    
    @IBAction func saveToTEFromCS (_ segue: UIStoryboardSegue) {
        
        //From CalendarSettingVC
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        dateFormatter.calendar = appDelegate.gregorianCalendar as Calendar!
        dateFormatter.timeStyle = DateFormatter.Style.short
        tableName = timetable!.timetableName
        numberOfClasses = timetable!.numberOfClasses.intValue
        showTime = timetable!.showTime
        timeIsSet = timetable!.timeIsSet
        courseTimes = model.fetchCourseTimes(timetable: timetable!)
        
        if !appDelegate.alreadyPurchased {
            interstitial = createAndLoadInterstitial()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        syncOn = timetable!.syncOn
        tableView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.cloudDataDidDownload(notification:)), name: .CDEICloudFileSystemDidDownloadFiles, object: nil)
    }
    
    
    @objc func cloudDataDidDownload(notification: Notification) {
        
        defaultStack.sync(completion: nil)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - TextField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: - TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3//一時的にCalendar 同期を使えなくする
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return titleForHeader[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 1 && timeIsSet && courseTimes!.count != 0) {
            return numberOfClasses! + 2
        } else if(section == 1 && !timeIsSet) {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell?
        switch indexPath.section {
            case 0: cell = tableView.dequeueReusableCell(withIdentifier: "tableNameCell", for: indexPath)
                    (cell as! TableNameCell).tableNameField.text = tableName
            case 1: switch indexPath.row {
                case 0: cell = tableView.dequeueReusableCell(withIdentifier: "toTimeSettingCell", for: indexPath)
                case 1: cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath)
                    let timeSwitch: UISwitch = UISwitch()
                    timeSwitch.addTarget(self, action: #selector(timeSwitchChanged), for: UIControlEvents.valueChanged)
                    cell?.accessoryView = timeSwitch
                    if(timeIsSet) {
                        timeSwitch.isEnabled = true
                    } else {
                        timeSwitch.isEnabled = false
                    }
                    if(showTime) {
                        timeSwitch.isOn = true
                    } else {
                        timeSwitch.isOn = false
                    }
                default: cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath)
                    configureTimeCell(indexPath: indexPath, cell: cell!)
                }
            default: cell = tableView.dequeueReusableCell(withIdentifier: "syncCell", for: indexPath)
                    if(syncOn) {
                        cell?.detailTextLabel?.text = "ON"
                    } else {
                        cell?.detailTextLabel?.text = "OFF"
                    }
        }
        return cell!
    }
    
    
    override func tableView (_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                //toTimeSetting
                performSegue(withIdentifier: "toTimeSetting", sender: self)
            } else if (indexPath.row >= 2) {
                //ToEachTimeView
                selectedPeriod = indexPath.row - 1
                performSegue(withIdentifier: "toEachTime", sender: self)
            }
        } else if (indexPath.section == 2 && indexPath.row == 0) {
            //toCalendarSettingView
            if(timeIsSet) {
                performSegue(withIdentifier: "toCalendarSetting", sender: self)
            } else {
                showTimeSettingAlert()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func configureTimeCell (indexPath: IndexPath, cell: UITableViewCell) {
        
        let period: Int = indexPath.row - 1
        cell.textLabel?.text = period.ordinal + NSLocalizedString("period", comment: "限")
        let startTime = model.startTime(period: period, courseTimes: courseTimes!)
        let endTime = model.endTime(period: period, courseTimes: courseTimes!)
        cell.detailTextLabel?.text = dateFormatter.string(from: startTime) + " ~ " + dateFormatter.string(from: endTime)
    }
    
    
    @objc func timeSwitchChanged(_ sender: UISwitch) {
        
        if(sender.isOn) {
            showTime = true
        } else {
            showTime = false
        }
    }
    
    
    // MARK: - Navigation

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == nil) {
            return
        }
        switch segue.identifier! {
            case "toCalendarSetting":
                //To CalendarSettingViewController
                let controller = segue.destination as! CalendarSettingViewController
                controller.timetable = timetable!
                controller.courseTimes = courseTimes
            case "toTimeSetting":
                //To EasySettingVC
                let controller = segue.destination as! EasySettingViewController
                controller.timetable = timetable!
                controller.courseTimes = courseTimes!
            case "toEachTime":
                //To EachTimeVC
                let controller = segue.destination as! EachTimeViewController
                controller.courseTimes = courseTimes
                controller.selectedPeriod = selectedPeriod
            case "saveToTableFromEdit":
                //Unwind to TimeTableVC
                let controller = segue.destination as! TimeTableViewController
                controller.timetable = timetable!
                controller.courseTimes = courseTimes!
            default: return
        }
    }
    
    
    //Utilities
    
    func showTimeSettingAlert() {
        
        let title = "Notice"
        let message = NSLocalizedString("FirstPleaseSetClassHours", comment: "先に授業時間を設定してください")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - AdMob
    
    func createAndLoadInterstitial() -> GADInterstitial {
        
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-7686010266932149/3513620919")
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "2077ef9a63d2b398840261c8221a0c9b"]
        interstitial.delegate = self
        interstitial.load(request)
        return interstitial
    }
    
    
    // MARK: - GADInterstitialDelegate
    
    //広告がロードされたタイミングで表示
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        
        interstitial.present(fromRootViewController: self)
    }
    
}
