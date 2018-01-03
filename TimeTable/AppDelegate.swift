//
//  AppDelegate.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/03/10.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit
import CoreData
import StoreKit
import Firebase
import Ensembles

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    
    let eventStore = EventStore.shared
    let userDefaults = UserDefaults.standard
    let defaultsDict: [String: AnyObject] = ["themaColor": 0 as AnyObject, "purchased": false as AnyObject]
    let defaultStack = CoreDataStack.shared
    let gregorianCalendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    
    var selectedUUID: String? = nil
    let days: [String] = [NSLocalizedString("MF", comment: "月-金"), NSLocalizedString("MSat", comment: "月-土"), NSLocalizedString("MSun", comment: "月-日")]//これはそのままエンティティに格納されるので、アップデートでも変更不可。
    let numOfClasses: [Int] = [4, 5, 6, 7, 8, 9, 10, 11, 12]
    let detailColors = ["Purple", "Pink", "Rose", "Capucine", "Orange", "Yellow", "LightGreen", "EmeraldGreen", "CadetBlue", "LightBlue", "Blue", "Navy", "Black"]
    let themeColors: [String] = ["Jade", "PeterRiver", "SkyBlue", "Amethyst", "Sakura", "Alizarin",  "Orange", "SunFlower", "Asbestos"]
    
    let dayName = [NSLocalizedString("Mon", comment: "月曜"), NSLocalizedString("Tue", comment: "火曜"), NSLocalizedString("Wed", comment: "水曜"), NSLocalizedString("Thu", comment: "木曜"), NSLocalizedString("Fri", comment: "金曜"), NSLocalizedString("Sat", comment: "土曜"), NSLocalizedString("Sun", comment: "日曜")]


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        CDESetCurrentLoggingLevel(CDELoggingLevel.verbose.rawValue)
        
        // Override point for customization after application launch
        userDefaults.register(defaults: defaultsDict)
        
        // Setup Ensemble
        defaultStack.enableEnsembles()
        defaultStack.sync(completion: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.localSaveOccured(notification:)), name: .CDEMonitoredManagedObjectContextDidSave, object: nil)
        defaultStack.sync(completion: nil)
        
        //EventKit
        eventStore.checkAuthorizationStatus()
        
        SKPaymentQueue.default().add(StoreKitAccessor.shared)
        
        //Firebase
        FirebaseApp.configure()

        print("premium: \(alreadyPurchased)")
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let detailNavigationController = splitViewController.viewControllers.last as! UINavigationController
        let detailViewController = detailNavigationController.topViewController as! TimeTableViewController
        selectedUUID = userDefaults.string(forKey: "selectedUUID")
        detailViewController.timetable = detailViewController.model.fetchTimetableWith(uuid: selectedUUID)
        if (detailViewController.timetable == nil) {
            splitViewController.preferredDisplayMode = .primaryOverlay
        } else {
            splitViewController.preferredDisplayMode = .automatic
        }
        
        splitViewController.delegate = self
        
        return true
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let taskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        defaultStack.saveContext()
        defaultStack.sync {
            UIApplication.shared.endBackgroundTask(taskIdentifier)
        }
        SKPaymentQueue.default().remove(StoreKitAccessor.shared)
    }

    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        defaultStack.sync(completion: nil)
        SKPaymentQueue.default().add(StoreKitAccessor.shared)
    }

    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        defaultStack.sync(completion: nil)
    }

    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        defaultStack.saveContext()
    }

    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NSLog("Received a remote notification")
    }
    
    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        
        let secondaryAsNavController = secondaryViewController as! UINavigationController
        let detailViewController = secondaryAsNavController.topViewController as! TimeTableViewController
        if detailViewController.timetable == nil {
            return true
        } else {
            return false
        }
    }
 
    
    @objc func localSaveOccured(notification: Notification) {
        print("AppDelegate: Local save occured")
        defaultStack.sync(completion: nil)
    }
 
    
    // MARK: - In App Purchase
    
    var alreadyPurchased: Bool = {
        let icloudKeyValueStore = NSUbiquitousKeyValueStore.default
        let icloud = icloudKeyValueStore.bool(forKey: "purchased")
        print("icloud: \(icloud)")
        let local = UserDefaults.standard.bool(forKey: "purchased")
        print("local: \(local)")
        if icloud || local {
            print("購入済み")
            StoreKitAccessor.shared.setPurchasedTrue()
            return true
        } else {
            return false
        }
    }()
    
}

