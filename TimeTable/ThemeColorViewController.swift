//
//  ThemaColorViewController.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2015/03/27.
//  Copyright (c) 2015年 Shuhei Fujita. All rights reserved.
//

import UIKit

class ThemeColorViewController: UITableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedColor: Int?
    
    @IBAction func saveButtonPushed(_ sender: UIBarButtonItem) {
        appDelegate.userDefaults.set(selectedColor!, forKey: "themaColor")
        let success = appDelegate.userDefaults.synchronize()
        if success {
            print("defaults保存")
        } else {
            print("defaults 保存失敗")
        }
        navigationController?.setColor()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedColor = appDelegate.userDefaults.integer(forKey: "themaColor")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.selectRow(at: IndexPath(row: selectedColor!, section: 0), animated: true, scrollPosition: .none)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return appDelegate.themeColors.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeColorCell", for: indexPath) as! ThemeColorCell
        // Configure the cell...
        //makeCell →checkLabelの順番
        cell.makeCell(color: indexPath.row)
        if(cell.isSelected) {
            cell.checkLabel.isHidden = false
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! ThemeColorCell
        selectedCell.makeCell(color: indexPath.row)
        selectedCell.checkLabel.isHidden = false
        selectedColor = indexPath.row
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if(tableView.cellForRow(at: indexPath) != nil) {
            //画面内にないセルについて生成するとエラーになるので、nilチェック
            let deselectedCell = tableView.cellForRow(at: indexPath) as! ThemeColorCell
            deselectedCell.makeCell(color: indexPath.row)
            if indexPath.row == 11 {
                //cloudsColor 元にもどす
                deselectedCell.checkLabel.textColor = UIColor.white
            }
        }
    }
}
