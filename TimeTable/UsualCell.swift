//
//  UsualCell.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/03/14.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit

class UsualCell: UICollectionViewCell {
    
 
    @IBOutlet weak var leftLine: UIView!
    @IBOutlet weak var lessonNameLabel: UILabel!
    @IBOutlet weak var roomNameLabel: UILabel!


    func makeCell (classes: Classes) {
    
        //枠線
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        
        let color = Int(classes.color)
        self.backgroundColor = UIColor.cellBackColor(color: color)
        leftLine.backgroundColor = UIColor.cellLineColor(color: color)
        lessonNameLabel.textColor = UIColor.cellLabelColor(color: color)
        roomNameLabel.textColor = UIColor.cellLabelColor(color: color)
        lessonNameLabel.text = classes.lessonName
        roomNameLabel.text = classes.roomName
        
        //font
        var fontSize: CGFloat = self.frame.size.height/10
        if fontSize < 12 {
            fontSize = 12
        } else if fontSize > 20 {
            fontSize = 20
        }
        lessonNameLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
        roomNameLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
    }
    
    
    func cellSelected (color: Int) {
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        self.backgroundColor = UIColor.cellLineColor(color: color)
        leftLine.backgroundColor = UIColor.cellLineColor(color: color)
        lessonNameLabel.textColor = UIColor.white
        roomNameLabel.textColor = UIColor.white
    }
 
    
    func clearUsualCell () {
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        //dequeuereusablecellなので、しっかり空に
        self.backgroundColor = UIColor.white
        leftLine.backgroundColor = UIColor.white
        lessonNameLabel.text = nil
        roomNameLabel.text = nil
    }
    
    
    func cellIsDestination() {
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        
        leftLine.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.lightGray
        leftLine.backgroundColor = UIColor.lightGray
        self.isUserInteractionEnabled = false
        lessonNameLabel.text = nil
        roomNameLabel.text = nil
    }
}
