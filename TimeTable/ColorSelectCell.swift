//
//  ColorSelectCell.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/05/16.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit

class ColorSelectCell: UITableViewCell {
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorSideView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    
    
    func makeCell(color: Int) {
        
        colorView.backgroundColor = UIColor.cellBackColor(color: color)
        colorSideView.backgroundColor = UIColor.cellLineColor(color: color)
        colorLabel.text = appDelegate.detailColors[color]
        colorLabel.textColor = UIColor.cellLabelColor(color: color)
    }
    
}
