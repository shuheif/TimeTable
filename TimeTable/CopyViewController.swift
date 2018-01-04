//
//  CopyViewController.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/09/18.
//  Copyright © 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit

class CopyViewController: WeekViewController {
    
    var destinationIndexPath: IndexPath?
    var copyIndexPath: IndexPath?
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBAction func doneButtonPushed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "doneToDetailFromCopy", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isToolbarHidden = true
        doneButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }
    
    override func collectionView (_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath == destinationIndexPath) {
            //引用先のセル
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UsualCell", for: indexPath) as! UsualCell
            cell.cellIsDestination()
            return cell
        } else if (indexPath == copyIndexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UsualCell", for: indexPath) as! UsualCell
            let ClassesObject: Classes? = classesAtIndexPath(classes: classes!, indexPath: indexPath)
            if(ClassesObject != nil) {
                cell.cellSelected(color: ClassesObject!.color.intValue)
            }
            return cell
        } else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
    }
    
    override func collectionView (_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //選択できるのはClasses != nilのセルのみ
        if (copyIndexPath != nil) {
            let beforeCell = collectionView.cellForItem(at: copyIndexPath!) as! UsualCell
            let beforeClasses: Classes? = classesAtIndexPath(classes: classes!, indexPath: indexPath)
            if(beforeClasses != nil) {
                beforeCell.makeCell(classes: beforeClasses!)
            }
        }
        copyIndexPath = indexPath
        let afterCell = collectionView.cellForItem(at: indexPath) as! UsualCell
        let afterClasses: Classes? = classesAtIndexPath(classes: classes!, indexPath: indexPath)
        if(afterClasses != nil) {
            afterCell.cellSelected(color: Int(truncating: afterClasses!.color))
        }
        doneButton.isEnabled = true
    }
    
    override func configureUsualCell (indexPath: IndexPath, usualCell: UsualCell) {
        let aClass: Classes? = classesAtIndexPath(classes: classes!, indexPath: indexPath)
        if(aClass != nil) {
            usualCell.makeCell(classes: aClass!)
            usualCell.isUserInteractionEnabled = true
        } else {
            usualCell.clearUsualCell()
            usualCell.isUserInteractionEnabled = false
        }
    }
    
    // MARK: - Navigation
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "doneToDetailFromCopy") {
            let controller = segue.destination as! DetailViewController
            let aClass: Classes? = classesAtIndexPath(classes: classes!, indexPath: copyIndexPath!)
            if(aClass != nil) {
                controller.lessonNameField.text = aClass!.lessonName
                controller.teacherNameField.text = aClass!.teacherName
                controller.roomNameField.text = aClass!.roomName
                controller.memoView.text = aClass!.memo
                controller.selectedColor = aClass!.color.intValue
            }
        }
    }
}
