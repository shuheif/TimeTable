//
//  UIViewExtension.swift
//  TimeTable
//
//  Created by Shuhei Fujita on 2017/01/02.
//  Copyright © 2017年 Shuhei Fujita. All rights reserved.
//
import Foundation

extension UIView {
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
}
