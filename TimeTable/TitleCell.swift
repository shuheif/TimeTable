//
//  TitleCell.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/03/14.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit

class TitleCell: UICollectionViewCell {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    func clearTitleCell () {
        
        //dequeuereusablecellなので、しっかり空に
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        startLabel.text = nil
        titleLabel.text = nil
        endLabel.text = nil
        self.backgroundColor = UIColor.white
    }
    
    
    func configureHeaderCell (rowIndex: Int) {
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        startLabel.text = nil
        endLabel.text = nil
        self.backgroundColor = UIColor.white
        titleLabel.textColor = UIColor.black
        titleLabel.text = appDelegate.dayName[rowIndex - 1]
    }
    
    //その日の曜日を黒く表示して他と区別する
    func configureHeaderCell (rowIndex: Int, weekDays: Int) {
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        startLabel.text = nil
        endLabel.text = nil
        titleLabel.text = appDelegate.dayName[rowIndex - 1]
        if rowIndex == weekDays {
            self.backgroundColor = UIColor.lightGray
            titleLabel.textColor = UIColor.white
        } else {
            self.backgroundColor = UIColor.white
            self.titleLabel?.textColor = UIColor.black
        }
    }
    
    
    func configureSideCell(period: Int) {
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        startLabel.text = nil
        endLabel.text = nil
        self.backgroundColor = UIColor.white
        titleLabel.text = String(period)
    }
    
    
    func configureSideCell(cell: TitleCell, period: Int, startTime: String, endTime: String) {
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        self.backgroundColor = UIColor.white
        titleLabel.text = String(period)
        startLabel.text = startTime
        endLabel.text = endTime
    }

}
