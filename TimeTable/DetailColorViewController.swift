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
    var selectedColor: Int = 0
    var cellwidth: CGFloat = 62.99//通常セルの幅
    var cellheight: CGFloat = 103.8//通常セルの高さ
    
    @IBAction func doneButtonPushed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "UnwindDetailColorToDetail", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - UICollectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.detailColors.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        colorCell.makeCell(color: indexPath.row)
        colorCell.colorLabel.text = appDelegate.detailColors[indexPath.row]
        if (indexPath.row == selectedColor) {
            colorCell.checkView.isHidden = false
        }
        return colorCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedColor = indexPath.row
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "UnwindDetailColorToDetail":
            let controller = segue.destination as! DetailViewController
            controller.selectedColor = selectedColor
        default:
            break
        }
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
