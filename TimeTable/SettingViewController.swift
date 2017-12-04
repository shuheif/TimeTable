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
        if appDelegate.alreadyPurchased {
            upgradeCell.selectionStyle = .none
        } else {
            upgradeCell.selectionStyle = .default
        }
        versionNameCell.detailTextLabel!.text = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
    }

    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 2 {
            //サポートセクション
            if indexPath.row == 0 {
                //HomePage
                let url = URL(string: "http://timetable.strikingly.com")!
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(url)
                }
            } else if indexPath.row == 1 {
                //Facebook
                let url = URL(string: "https://www.facebook.com/classscheduler")!
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(url)
                }
            } else if indexPath.row == 2 {
                //AppStore
                openAppStore()
            }
        } else if indexPath.section == 4 {
            print("reset")
            
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
    
    
    func openAppStore() {
        
        let url: URL = URL(string: "https://itunes.apple.com/jp/app/timetable-shinpurude-shiiyasui/id981480777?mt=8")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
    }
    
}
