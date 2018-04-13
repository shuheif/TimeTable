//
//  WeekViewController.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/09/18.
//  Copyright © 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit
import CoreData

class WeekViewController: UICollectionViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var dateFormatter = DateFormatter()
    let header: CGFloat = 20//headerの高さ
    var sider: CGFloat = 20//siderの幅
    var frameWidth: CGFloat?//frameの幅
    var frameHeight: CGFloat?//frameの高さ
    var cellWidth: CGFloat?//セルの幅
    var cellHeight: CGFloat?//セルの高さ
    var intDays: Int?//曜日数
    var intClasses: Int?//時限数
    var floatDays: CGFloat?
    var floatClasses: CGFloat?
    var timetable: Timetables?//WeekViewClass初期化時に必要
    var classes: [Classes]?//同上
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.toolbar.isHidden = true
        let usualNib = UINib(nibName: "UsualCell", bundle: nil)
        let titleNib = UINib(nibName: "TitleCell", bundle: nil)
        collectionView?.register(usualNib, forCellWithReuseIdentifier: "UsualCell")
        collectionView?.register(titleNib, forCellWithReuseIdentifier: "TitleCell")
        if timetable != nil {
            intDays = timetable!.numberOfDays.intValue + 5// 換算 曜日数
            intClasses = timetable!.numberOfClasses.intValue // 時限数
            floatDays = CGFloat(intDays!)
            floatClasses = CGFloat(intClasses!)
        }
        self.navigationItem.leftItemsSupplementBackButton = true
        dateFormatter.calendar = appDelegate.gregorianCalendar
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("viewWillTransition")
        guard let flowLayout = collectionView?.collectionViewLayout  else {
            print("flowLayout return")
            return
        }
        flowLayout.invalidateLayout()
    }
    
    // MARK: UICollectionView
    override func collectionView (_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if timetable != nil {
            return (intDays! + 1) * (intClasses! + 1)
        } else {
            return 0
        }
    }
    
    override func collectionView (_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if ((indexPath as NSIndexPath).row <= intDays!) || ((indexPath as NSIndexPath).row % (intDays! + 1) == 0){
            let titleCell: TitleCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TitleCell", for: indexPath) as! TitleCell
            if((indexPath as NSIndexPath).row == 0) {
                titleCell.clearTitleCell()
            } else if ((indexPath as NSIndexPath).row <= intDays!){
                //header
                configureHeaderCell(titleCell: titleCell, rowPath: (indexPath as NSIndexPath).row)
            } else if((indexPath as NSIndexPath).row % (intDays! + 1) == 0) {
                //sider
                configureSideCell(titleCell: titleCell, period: (indexPath as NSIndexPath).row / (intDays! + 1))
            }
            return titleCell
        } else {
            let usualcell: UsualCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UsualCell", for: indexPath) as! UsualCell
            self.configureUsualCell(indexPath: indexPath, usualCell: usualcell)
            return usualcell
        }
    }
    
    func configureHeaderCell (titleCell: TitleCell, rowPath: Int) {
        titleCell.configureHeaderCell(rowIndex: rowPath)
    }
    
    func configureSideCell (titleCell: TitleCell, period: Int) {
        titleCell.configureSideCell(period: period)
    }
    
    func configureUsualCell (indexPath: IndexPath, usualCell: UsualCell) {
        let aClass: Classes? = classesAtIndexPath(classes: classes!, indexPath: indexPath)
        if(aClass != nil) {
            usualCell.makeCell(classes: aClass!)
        } else {
            usualCell.clearUsualCell()
        }
    }
    
    /*  classesAtIndexPath
    *   classesObjects配列から、classesObjext.indexPathが当てはまるものを取得
    */
    func classesAtIndexPath (classes: [Classes], indexPath: IndexPath) -> Classes? {
        for aClass in classes {
            if aClass.indexPath == NSNumber(value: Int32(indexPath.row)) {
                return aClass
            }
        }
        return nil
    }
}


extension WeekViewController: UICollectionViewDelegateFlowLayout {
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //Calculates cell sizes
        let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        frameHeight = self.collectionView!.frame.height - navigationBarHeight - statusBarHeight
        frameWidth = self.collectionView!.frame.width
        var height: CGFloat = ((frameHeight! - header) / floatClasses!)
        var width: CGFloat = (frameWidth! - sider) / floatDays! - 0.01
        
        if (indexPath as NSIndexPath).row <= intDays! {
            //１行目
            height = header
        }
        if (indexPath as NSIndexPath).row % (intDays! + 1) == 0 {
            //１列目
            width = sider
        }
        return CGSize(width: width, height: height)
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
