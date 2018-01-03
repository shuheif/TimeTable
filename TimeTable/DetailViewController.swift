//
//  DetailViewController.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/03/27.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let model = DetailViewModel.shared
    
    var timetable: Timetables?
    var classes: [Classes]?//CopyViewへの引き継ぎ
    var aClass: Classes?
    var courseTimes: [CourseTimes]?
    var selectedIndexPath: IndexPath?
    var day: String?
    var time: Int?
    var selectedColor: Int = 0
    
    let days = [NSLocalizedString("DMon", comment: "月曜"), NSLocalizedString("DTue", comment: "火曜"), NSLocalizedString("DWed", comment: "水曜"), NSLocalizedString("DThu", comment: "木曜"), NSLocalizedString("DFri", comment: "金曜"), NSLocalizedString("DSat", comment: "土曜"), NSLocalizedString("DSun", comment: "日曜")]

    @IBOutlet weak var lessonNameField: UITextField!
    @IBOutlet weak var numberCell: UITableViewCell!
    @IBOutlet weak var teacherNameField: UITextField!
    @IBOutlet weak var roomNameField: UITextField!
    @IBOutlet weak var colorSelectCell: ColorSelectCell!
    @IBOutlet weak var memoView: UITextView!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var copyButton: UIBarButtonItem!
    
    
    @IBAction func backToDetail(_ segue: UIStoryboardSegue) {
    
        colorSelectCell.makeCell(color: selectedColor)
    }
    
    
    @IBAction func cancelToDetail(_ segue: UIStoryboardSegue) {
    }
    
    
    @IBAction func doneToDetailFromCopy (_ segue: UIStoryboardSegue) {
        
        colorSelectCell.makeCell(color: selectedColor)
    }
    
    
    @IBAction func saveButtonPushed (_ sender: UIBarButtonItem) {
        
        var isNewClasses = false
        if aClass == nil {
            isNewClasses = true
        }
        aClass = model.saveAClass(aClass: aClass, timetable: timetable!, lessonName: lessonNameField.text, teacherName: teacherNameField.text, roomName: roomNameField.text, memo: memoView.text, color: selectedColor, indexPath: selectedIndexPath!)
        if timetable!.syncOn {
            //カレンダーに変更を反映
            if isNewClasses {
                //期間中この授業だけ同期
                let startDate: Date? = timetable!.startDate as Date
                let endDate: Date? = timetable!.endDate as Date
                if startDate != nil && endDate != nil {
                    model.saveEventDuringTerm(startDate: startDate!, endDate: endDate!, aClass: aClass!, timetable: timetable!, indexPath: selectedIndexPath!, courseTimes: courseTimes!, title: lessonNameField.text!, location: roomNameField.text!)
                }
            } else {
                //授業名・教室名の変更だったら
                model.editEvents(aClass: aClass!)
            }
        }
        performSegue(withIdentifier: "saveToTimeTable", sender: self)
    }
    
    
    @IBAction func trashButtonPushed (_ sender: UIBarButtonItem) {
        
        //カレンダーに変更を反映
        model.deleteAssociatedEvents(aClass: aClass)
        model.deleteClasses(aClass: aClass)
        self.performSegue(withIdentifier: "saveToTimeTable", sender: self)
    }
    
    
    @IBAction func copyButtonPushed(_ sender: UIBarButtonItem) {
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        aClass = model.classAt(indexPath: selectedIndexPath!, classes: classes!, timetable: timetable!)
        
        //曜日/時限数セル
        let numberOfDays = timetable!.numberOfDays.intValue + 5
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        let period = selectedIndexPath!.row / (numberOfDays + 1)
        day = days[selectedIndexPath!.row % (numberOfDays + 1) - 1]
        numberCell.detailTextLabel?.text = day! + " " +  period.ordinal + NSLocalizedString("period", comment: "限")
        
        //その他セル
        if(aClass != nil) {
            lessonNameField.text = aClass!.lessonName
            teacherNameField.text = aClass!.teacherName
            roomNameField.text = aClass!.roomName
            memoView.text = aClass!.memo
            selectedColor = aClass!.color.intValue
        }
        
        //色選択セル
        colorSelectCell.makeCell(color: selectedColor)
      
        //キーボード表示の通知
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        //navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = false
        if(aClass == nil) {
            trashButton.isEnabled = false
            copyButton.isEnabled = true
        } else {
            trashButton.isEnabled = true
            copyButton.isEnabled = false
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.view.endEditing(true)//Keyboardが出ている途中、DetailColorへ行き戻るとkeyboardwillshow textIndexPathがnilのエラー
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        let center = NotificationCenter.default
        center.removeObserver(self, name: NSNotification.Name(rawValue: "keyboardWillShow:"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Keyboard
    
    @objc func keyboardWillShow(_ notification: Notification!) {
        
        //storyboardのtableview>scrollview>keyboard>'dismiss on drag'
        var textIndexPath: IndexPath?
        if(lessonNameField.isFirstResponder) {
            textIndexPath = IndexPath(row: 0, section: 0)
        } else if(teacherNameField.isFirstResponder) {
            textIndexPath = IndexPath(row: 1, section: 1)
        } else if(roomNameField.isFirstResponder) {
            textIndexPath = IndexPath(row: 2, section: 1)
        } else if(memoView.isFirstResponder) {
            textIndexPath = IndexPath(row: 0, section: 3)
        } else {
            return
        }
        tableView.scrollToRow(at: textIndexPath!, at: UITableViewScrollPosition.top, animated: true)
    }
    
    
    // MARK: - TableView
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // MARK: - TextField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goDetailColor" {
            
            let controller = segue.destination as! DetailColorViewController
            controller.selectedIndexPath = selectedColor
        } else if segue.identifier == "goCopy" {
            
            //To CopyView
            let controller = (segue.destination as! UINavigationController).topViewController as! CopyViewController
            controller.timetable = timetable
            controller.classes = classes
            controller.destinationIndexPath = selectedIndexPath!
        }
    }
    
}
