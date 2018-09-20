//
//  SettingViewController.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/03/26.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit
import StoreKit
import SVProgressHUD

class SettingViewController: UITableViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var themeCell: UITableViewCell!
    @IBOutlet weak var premiumCell: UITableViewCell!
    @IBOutlet weak var homepageCell: UITableViewCell!
    @IBOutlet weak var facebookCell: UITableViewCell!
    @IBOutlet weak var storeCell: UITableViewCell!
    @IBOutlet weak var appNameCell: UITableViewCell!
    @IBOutlet weak var versionNameCell: UITableViewCell!
    @IBOutlet weak var copyRightCell: UITableViewCell!
    @IBOutlet weak var upgradeCell: UITableViewCell!
    
    @IBAction func cancelToSetting(_ segue: UIStoryboardSegue) {
        for navController in splitViewController!.viewControllers {
            (navController as! UINavigationController).setColor()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upgradeCell.selectionStyle = appDelegate.alreadyPurchased ? .none : .default
        versionNameCell.detailTextLabel!.text = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            //サポートセクション
            var url: URL?
            switch indexPath.row {
            case 0:
                url = URL(string: "http://timetable.strikingly.com")!
            case 1:
                url = URL(string: "https://www.facebook.com/classscheduler")!
            default:
                //case 2
                openAppStore()
            }
            if url != nil {
                UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        } else if indexPath.section == 4 {
            //Alert
            let title = NSLocalizedString("deletingAll", comment: "")
            let message = NSLocalizedString("deletingAllMessage", comment: "")
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { void in
                SVProgressHUD.setDefaultMaskType(.black)
                SVProgressHUD.setMinimumDismissTimeInterval(1)
                SVProgressHUD.show(withStatus: "Deleting")
                DispatchQueue.global().async {
                    SettingViewModel.shared.deleteAllData()
                    DispatchQueue.main.async {
                        SVProgressHUD.showSuccess(withStatus: "Deleted")
                        //Done alert
                        let doneMessage = NSLocalizedString("takingTimeMessage", comment: "")
                        let doneAlert = UIAlertController(title: nil, message: doneMessage, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        doneAlert.addAction(okAction)
                        self.present(doneAlert, animated: true, completion: nil)
                    }
                }
            })
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            present(alert, animated: true, completion: nil)
            
            //Done alert
            let doneMessage = NSLocalizedString("takingTimeMessage", comment: "")
            let doneAlert = UIAlertController(title: nil, message: doneMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            doneAlert.addAction(okAction)
            present(doneAlert, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}


extension SettingViewController: SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func openAppStore() {
        let storeProductViewController = SKStoreProductViewController()
        storeProductViewController.delegate = self
        let parameters = [SKStoreProductParameterITunesItemIdentifier: "981480777"]
        storeProductViewController.loadProduct(withParameters: parameters, completionBlock: { (status, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
        self.present(storeProductViewController, animated: true, completion: nil)
    }
}
