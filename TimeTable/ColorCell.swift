//
//  ColorCell.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/05/16.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {
    
    
    @IBOutlet weak var leftLine: UIView!
    @IBOutlet weak var checkView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    
    
    func makeCell(color: Int) {
        
        self.backgroundColor = UIColor.cellBackColor(color: color)
        leftLine.backgroundColor = UIColor.cellLineColor(color: color)
        colorLabel.textColor = UIColor.cellLabelColor(color: color)
        checkView.isHidden = true
        
        let selectedBackGroundView: UIView = UIView()
        selectedBackGroundView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        self.selectedBackgroundView = selectedBackGroundView
        
    }

}
