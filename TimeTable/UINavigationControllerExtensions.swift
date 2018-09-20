//
//  CustomNavigationViewController.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/03/10.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit

extension UINavigationController {

    override open func viewDidLoad() {
        super.viewDidLoad()
        setColor()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        super.viewWillAppear(true)
        setColor()
    }
    
    
    func setColor() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let color = UIColor.themeColor(num: appDelegate.userDefaults.integer(forKey: "themaColor"))
        navigationBar.barTintColor = color
        toolbar.barTintColor = color
        navigationBar.tintColor = UIColor.white
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        toolbar.tintColor = UIColor.white
    }
}
