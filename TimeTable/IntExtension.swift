//
//  IntExtension.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2016/12/20.
//  Copyright © 2016年 Shuhei Fujita. All rights reserved.
//

import Foundation

extension Int {
    
    var ordinal: String {
        
        if isLocaleJapanese() {
            return "\(self)"
        } else {
            var suffix: String
            let ones: Int = self % 10
            let tens: Int = (self / 10) % 10
            
            if tens == 1 {
                suffix = "th"
            } else if ones == 1 {
                suffix = "st"
            } else if ones == 2 {
                suffix = "nd"
            } else if ones == 3 {
                suffix = "rd"
            } else {
                suffix = "th"
            }
            return "\(self)\(suffix)"
        }
        
    }
    
    func isLocaleJapanese() -> Bool {
        
        let languages = NSLocale.preferredLanguages
        let languageID: String = languages[0]
        
        if languageID.hasPrefix("ja-") {
            return true
        } else {
            return false
        }
    }
}
