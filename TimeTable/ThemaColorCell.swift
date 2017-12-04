//
//  TableViewCell.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/06/10.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit

class ThemeColorCell: UITableViewCell {
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    
    
    func makeCell(color: Int) {
        
        self.colorView.backgroundColor = UIColor.themeColor(num: color)
        self.colorLabel.text = appDelegate.themeColors[color]
        self.checkLabel.isHidden = true
    }
}
