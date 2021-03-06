//
//  TimeTableViewController.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/03/13.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit
import CoreData

class TimeTableViewController: WeekViewController {
    
    let model = TimeTableViewModel.shared
    let defaultStack = CoreDataStack.shared
    var weekDays: Int?
    var selectedIndexPath: IndexPath?
    var showTime = false
    var timeIsSet = false
    var courseTimes: [CourseTimes] = []
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func saveToTimeTable (_ segue: UIStoryboardSegue) {
        updateUI()
    }
    
    @IBAction func saveToTableFromEdit (_ segue: UIStoryboardSegue) {
        configureTimeTableView()
        collectionView!.reloadData()
    }
    
    @IBAction func unwindDetailToTimeTable (_ segue: UIStoryboardSegue) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classes = model.fetchClasses(timetable: timetable)
        courseTimes = model.fetchCourseTimes(timetable: timetable)
        configureTimeTableView()
        
        dateFormatter.calendar = appDelegate.gregorianCalendar
        dateFormatter.dateFormat = "H:mm"
        weekDays = model.weekDays(now: Date())
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        
        editButton.isEnabled = (timetable != nil)
        self.collectionView.backgroundView = setupEmptyDataLabel()
    }
    
    private func setupEmptyDataLabel() -> UILabel {
        let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        emptyLabel.text = NSLocalizedString("TimeTableEmpty", comment: "Select a schedule to show")
        emptyLabel.textColor = UIColor.gray
        emptyLabel.sizeToFit()
        emptyLabel.textAlignment = .center
        return emptyLabel
    }
    
    func updateUI() {
        classes = model.fetchClasses(timetable: timetable)
        configureTimeTableView()
        collectionView!.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.isToolbarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.cloudDataDidDownload(notification:)), name: .CDEICloudFileSystemDidDownloadFiles, object: nil)
    }
    
    @objc func cloudDataDidDownload(notification: Notification) {
        print("[TimeTableView] cloudDataDidDownload")
        defaultStack.sync(completion: nil)
        configureTimeTableView()
        collectionView?.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: UICollectionView
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        collectionView.deselectItem(at: indexPath, animated: true)
        performSegue(withIdentifier: "goDetail", sender: self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! UsualCell
        let aClass: Classes? = super.classesAtIndexPath(classes: classes!, indexPath: indexPath)
        if aClass != nil {
            cell.cellSelected(color: aClass!.color.intValue)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! UsualCell
        let aClass: Classes? = super.classesAtIndexPath(classes: classes!, indexPath: indexPath)
        if(aClass != nil) {
            cell.makeCell(classes: aClass!)
        }
    }
    
    override func configureHeaderCell (titleCell: TitleCell, rowPath: Int) {
        titleCell.configureHeaderCell(rowIndex: rowPath)
    }
    
    override func configureSideCell (titleCell: TitleCell, period: Int) {
        if (showTime && courseTimes.count != 0) {
            let startTime = model.startTime(period: period, courseTimes: courseTimes)
            let endTime = model.endTime(period: period, courseTimes: courseTimes)
            
            titleCell.configureSideCell(cell: titleCell, period: period, startTime: dateFormatter.string(from: startTime), endTime: dateFormatter.string(from: endTime))
        } else {
            super.configureSideCell(titleCell: titleCell, period: period)
        }
    }
    
    // MARK: - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "goEdit":
            return (timetable != nil)
        default:
            return true
        }
    }
    
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "goDetail":
            let detailView = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            detailView.timetable = timetable
            detailView.selectedIndexPath = selectedIndexPath!
            detailView.classes = classes
            detailView.courseTimes = courseTimes
        case "goEdit":
            let editView = (segue.destination as! UINavigationController).topViewController as!  TableEditViewController
            editView.timetable = timetable
        default:
            break
        }
    }
    
    // MARK: - Utility
    private func configureTimeTableView() {
        if (timetable == nil) { return }
        self.title = timetable!.timetableName
        showTime = timetable!.showTime
        timeIsSet = timetable!.timeIsSet
        //cell
        if(showTime && !courseTimes.isEmpty) {
            sider = 37
        } else {
            sider = 20
        }
    }
}
