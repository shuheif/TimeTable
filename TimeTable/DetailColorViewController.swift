//
//  DetailColorViewController.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/03/30.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit

class DetailColorViewController: UICollectionViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let model = DetailColorViewModel.shared
    let gridSpace: CGFloat = 1//隙間の幅
    let defaultFloatDays: CGFloat = 5
    let defaultFloatClasses: CGFloat = 5
    var classEntity: Classes?
    var cellwidth: CGFloat = 62.99//通常セルの幅
    var cellheight: CGFloat = 103.8//通常セルの高さ
    var selectedIndexPath: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (classEntity == nil) {
            //error
        }
        selectedIndexPath = classEntity!.color.intValue
    }
    
    //MARK: - UICollectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.detailColors.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        colorCell.makeCell(color: indexPath.row)
        colorCell.colorLabel.text = appDelegate.detailColors[indexPath.row]
        if (indexPath.row == selectedIndexPath!) {
            colorCell.checkView.isHidden = false
        }
        return colorCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath.row
        model.updateColor(color: selectedIndexPath!, classEntity: classEntity!)
        collectionView.reloadData()
    }
}


extension DetailColorViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellwidth, height: cellheight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return gridSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return gridSpace
    }
}
