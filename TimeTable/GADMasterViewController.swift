//
//  GADMasterViewController.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 1/13/18.
//  Copyright © 2018 Shuhei Fujita. All rights reserved.
//

import Foundation
import GoogleMobileAds

class GADMasterViewController: NSObject {
    
    static let shared: GADMasterViewController = {
        let instance = GADMasterViewController()
        return instance
    }()
    
    var bannerView: GADBannerView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    public func setupAd(rootViewController: UIViewController) {
        if appDelegate.alreadyPurchased {
            return
        }
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        rootViewController.view.addSubview(bannerView)
        rootViewController.view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: rootViewController.bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: rootViewController.view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        bannerView.adUnitID = "ca-app-pub-7686010266932149/8258967894"
        bannerView.rootViewController = rootViewController
        bannerView.load(GADRequest())
    }
}
