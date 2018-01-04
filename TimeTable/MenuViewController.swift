//
//  MenuTableViewController.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/03/10.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD
import SCLAlertView//Premium Versionの宣伝のみに使用
import DZNEmptyDataSet

class MenuViewController: UITableViewController {

    let defaultStack = CoreDataStack.shared
    let model = MenuViewModel.shared
    
    @IBAction func plusButtonPushed(_ sender: UIBarButtonItem) {
        if premiumValidated() {
            performSegue(withIdentifier: "goAdd", sender: self)
        }
    }
    
    @IBAction func addCompleted (_ segue: UIStoryboardSegue) {
        tableView.reloadData()
    }
    
    @IBAction func cancelToMenu (_ segue: UIStoryboardSegue) {
    }
    
    var selectedTimetables: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.emptyDataSetSource = self
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        navigationController?.toolbar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = false
        tableView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.cloudDataDidDownload(notification:)), name: .CDEICloudFileSystemDidDownloadFiles, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func cloudDataDidDownload(notification: Notification) {
        print("MenuVC cloudDataDidDownload")
        defaultStack.sync(completion: nil)
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        configureCell(cell: cell, atIndexPath: indexPath)
        return cell
    }
    
    // fetchedResultsController内でも使用
    func configureCell (cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let object = fetchedResultsController.object(at: indexPath)
        model.tagUUID(timetable: object)
        cell.textLabel!.text = object.timetableName
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        model.saveSelectedRow(indexPath: indexPath, frc: fetchedResultsController)
        performSegue(withIdentifier: "goTimeTable", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        print("moveRowAtIndexPath")
        model.setArchiveOrder(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath, frc: fetchedResultsController)
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteClosure = { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            //アラートビューを表示
            let title = NSLocalizedString("DeleteTableAlertTitle", comment: "時間割削除")
            let message = NSLocalizedString("DeleteTableAlertMessage", comment: "この時間割を削除してもよろしいですか？")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { void in
                SVProgressHUD.setDefaultMaskType(.black)
                SVProgressHUD.setMinimumDismissTimeInterval(1)
                SVProgressHUD.show(withStatus: "Deleting")
                DispatchQueue.global().async {
                    self.model.deleteTimetables(targetIndexPath: indexPath, frc: self.fetchedResultsController)
                    DispatchQueue.main.async {
                        SVProgressHUD.showSuccess(withStatus: "Deleted")
                        let detailNavigationController = self.splitViewController!.viewControllers.last as! UINavigationController
                        guard let timeTableViewController: TimeTableViewController = detailNavigationController.topViewController as? TimeTableViewController else {
                            //iPhone用
                            tableView.reloadData()
                            return
                        }
                        //iPad用
                        timeTableViewController.timetable = nil
                        timeTableViewController.title = nil
                        timeTableViewController.collectionView?.reloadData()
                        tableView.reloadData()
                    }
                }
            })
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        let deleteButton = UITableViewRowAction(style: .default, title: "Delete", handler: deleteClosure)
        
        let copyClosure = { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            if !self.premiumValidated() {
                return
            }
            DispatchQueue.global().async {
                self.model.copyTimetables(targetIndexPath: indexPath, frc: self.fetchedResultsController)
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
        
        let copyButton = UITableViewRowAction(style: .normal, title: "Copy", handler: copyClosure)
        
        return [deleteButton, copyButton]
    }
    
    
    // MARK: - Navigation

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTimeTable" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! TimeTableViewController
                controller.timetable = object
                //Master内でDetail選択時、MasterViewをdismiss
                let detailNavigationController = self.splitViewController!.viewControllers.last as! UINavigationController
                guard let _: TimeTableViewController = detailNavigationController.topViewController as? TimeTableViewController else {
                    //iPhone用
                    return
                }
                //iPad用
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.splitViewController?.preferredDisplayMode = .primaryHidden
                })
            }
        } else if segue.identifier == "goAdd" {
            let controller = (segue.destination as! UINavigationController).topViewController as! AddViewController
            controller.fetchedResultsController = fetchedResultsController
        }
    }
    
    
    // MARK: - Fetched results controller
    
    lazy var fetchedResultsController: NSFetchedResultsController<Timetables> = {
        let fetchRequest: NSFetchRequest<Timetables> = Timetables.fetchRequest()
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let orderDescriptor = NSSortDescriptor(key: "archiveOrder", ascending: true)
        let nameDesctiptor = NSSortDescriptor(key: "timetableName", ascending: false)
        
        fetchRequest.sortDescriptors = [orderDescriptor, nameDesctiptor]
        //archiveOrder default is 0. すべて0の時は昔通りtimetableNameの降順
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.managedObjectContext, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        
        do {
            try aFetchedResultsController.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return aFetchedResultsController
    }()
    
    // MARK: - Alert View
    
    func showPremiumAlert() {
        let title = NSLocalizedString("TimeTablePro", comment: "プレミアム版")
        let message = NSLocalizedString("PremiumAd", comment: "")
        SCLAlertView().showInfo(title, subTitle: message, closeButtonTitle: "OK")
    }
    
    func premiumValidated() -> Bool {
        let sectionInfo = fetchedResultsController.sections![0]
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if sectionInfo.numberOfObjects >= 1 && !appDelegate.alreadyPurchased {
            showPremiumAlert()
            return false
        } else {
            return true
        }
    }
}


extension MenuViewController: NSFetchedResultsControllerDelegate {
    
    private func controllerWillChangeContent(controller: NSFetchedResultsController<Timetables>) {
        self.tableView.beginUpdates()
    }
    
    private func controller(controller: NSFetchedResultsController<Timetables>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    private func controller(controller: NSFetchedResultsController<Timetables>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(cell: tableView.cellForRow(at: indexPath!)!, atIndexPath: indexPath!)
        case .move:
            //tableView.moveRow(at: indexPath!, to: newIndexPath!)
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [indexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}


extension MenuViewController: DZNEmptyDataSetSource {
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSLocalizedString("MenuLabel", comment: "右上の+ボタンを押して\n時間割を作成してください")
        return NSAttributedString(string: text)
    }
}
