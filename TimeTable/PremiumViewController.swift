//
//  PremiumViewController.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2017/01/02.
//  Copyright © 2017年 Shuhei Fujita. All rights reserved.
//

import UIKit
import StoreKit
import SVProgressHUD

class PremiumViewController: UITableViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var headerCell: UITableViewCell!
    @IBOutlet weak var upgradeCell: UITableViewCell!
    
    @IBAction func cancelPushed(_ sender: UIBarButtonItem) {
        SVProgressHUD.dismiss()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //upgradeCell.detailTextLabel?.text = "240円"
        headerCell.imageView?.image = UIImage(named: "premium")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if appDelegate.alreadyPurchased {
            showPurchasedAlert()
            return
        }
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                print("upgrade cell selected")
                addObservers()
                //アップグレードcell
                SVProgressHUD.show()
                DispatchQueue.global().async {
                    self.startPurchasing()
                }
            } else if indexPath.row == 2 {
                print("restore cell selected")
                addObservers()
                SVProgressHUD.show()
                DispatchQueue.global().async {
                    self.startRestoring()
                }
            }
        }
    }
    
    // MARK: - InAppPurchase
    func startPurchasing() {
        //アプリ内課金が使えるかどうかチェック
        if !SKPaymentQueue.canMakePayments() {
            //エラーメッセージを表示
            showLimitedAlert()
            return
        }
        //アイテムidのプロダクトがAppStoreに存在するかを確認。AppStoreの返答は、func productsRequestに返ってくる
        let set: Set<String> = ["TimeTablePremium"]
        let productRequest = SKProductsRequest(productIdentifiers: set)
        productRequest.delegate = self
        productRequest.start()
    }
    
    func startRestoring() {
        //アプリ内課金が使えるかどうかチェック
        if !SKPaymentQueue.canMakePayments() {
            //エラーメッセージを表示
            showLimitedAlert()
            return
        }
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - Alert
    func showPurchasedAlert() {
        let message = NSLocalizedString("Already", comment: "")
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    func showLimitedAlert() {
        let title = NSLocalizedString("PerchaseCheck", comment: "")
        let message = NSLocalizedString("PurchaseDeclined", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        removeObservers()
    }
    
    func showInvalidAlert() {
        let title = NSLocalizedString("ItemCheck", comment: "")
        let message = NSLocalizedString("InvalidItem", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        removeObservers()
    }
    
    @objc func upgradeCompleted(notification: Notification?) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            let title = NSLocalizedString("Done", comment: "")
            let message = NSLocalizedString("Successfully", comment: "")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            self.removeObservers()
        }
    }
    
    @objc func purchaseFailedAlert(notification: Notification?) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            let title = NSLocalizedString("Failed", comment: "")
            let message = NSLocalizedString("CouldntFinish", comment: "")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            self.removeObservers()
        }
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.upgradeCompleted), name: NSNotification.Name(rawValue: "UPGRADE_COMPLETED"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.purchaseFailedAlert), name: NSNotification.Name(rawValue: "PURCHASE_FAILED"), object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}


extension PremiumViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        //アイテムidが無効だった場合
        if response.invalidProductIdentifiers.count > 0 {
            showInvalidAlert()
            return
        }
        //アイテムidが有効だった場合、購入を要求
        SKPaymentQueue.default().add(StoreKitAccessor.shared)
        for product in response.products {
            if product.productIdentifier == "TimeTablePremium" {
                //アイテムの値段を提示して、最終確認？
                //displayStoreUI custom method p.16 アプリケーションのストアUIの表示　参照
                //upgradeCell.detailTextLabel?.text = StoreKitAccessor.priceForProduct(product: product as SKProduct)
                let payment = SKPayment(product: product as SKProduct)
                SKPaymentQueue.default().add(payment)
            }
        }
    }
}
