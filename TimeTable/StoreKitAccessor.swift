//
//  StoreKitAccessor.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2016/12/22.
//  Copyright © 2016年 Shuhei Fujita. All rights reserved.
//

import UIKit
import StoreKit

class StoreKitAccessor: NSObject, SKPaymentTransactionObserver {
    
    static let shared: StoreKitAccessor = {
        let instance = StoreKitAccessor()
        return instance
    }()
    
    
    //SKProduct情報から国に合わせた金額を取得して表示
    static func priceForProduct(product: SKProduct) -> String? {
        
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }
    
    
    // MARK: - SKPaymentTransactionObserver
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                print("処理中")
            case .purchased:
                //成功処理
                print("購入完了")
                queue.finishTransaction(transaction)
                setPurchasedTrue()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UPGRADE_COMPLETED"), object: nil)
            case .restored:
                print("restored")
                queue.finishTransaction(transaction)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UPGRADE_COMPLETED"), object: nil)
            case .failed:
                print("failed")
                queue.finishTransaction(transaction)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PURCHASE_FAILED"), object: nil)
                //リストアする
                SKPaymentQueue.default().restoreCompletedTransactions()
            default:
                print("default")
                queue.finishTransaction(transaction)
            }
        }
    }
    
    
    //トランザクションがキューから削除されると呼ばれる。このmethod内で対応する項目をアプリケーションのUIから削除する。
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        
        print("paymentQueue removedTransactions")
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                print(transaction.payment.productIdentifier)
            }
        }
        SKPaymentQueue.default().remove(self)
    }
    
    
    //StoreKitがトランザクションの復元を終了するとエラーの有無に応じて呼び出される。処理の失敗をUIを通して伝える
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        
        print("paymentQueue restoreCompletedTransactionsFailedWithError")
        if queue.transactions.count == 0 {
            SKPaymentQueue.default().remove(self)
        }
    }
    
    
    //リストア処理完了。処理の成功をUIを通して伝える
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
        print("paymentQueueRestoreCOmpletedTransactionsFinished")
        for transaction in queue.transactions {
            if transaction.transactionState == .purchased {
                print(transaction.payment.productIdentifier)
            }
            if queue.transactions.count == 0 {
                SKPaymentQueue.default().remove(self)
            }
        }
        setPurchasedTrue()
    }
    
    
    func setPurchasedTrue() {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "purchased")
        
        let icloudKeyValueStore = NSUbiquitousKeyValueStore.default
        icloudKeyValueStore.set(true, forKey: "purchased")
        icloudKeyValueStore.synchronize()
    }
    
    /*
    func setPurchasedFalse() {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(false, forKey: "purchased")
        
        let icloudKeyValueStore = NSUbiquitousKeyValueStore.default()
        icloudKeyValueStore.set(false, forKey: "purchased")
        icloudKeyValueStore.synchronize()
    }*/
    
}
