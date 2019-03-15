//
//  UIViewExtensions.swift
//  Will Robots Take Over the World Today?
//
//  Created by Milo Wyner on 3/10/19.
//  Copyright © 2019 Milo Wyner. All rights reserved.
//

import UIKit

// Adds fading in/out animations to UIView
extension UIView {
    func fadeOut(duration: TimeInterval = 0, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut, animations: {
            self.alpha = 0
        }, completion: completion)
    }
    
    func fadeIn(duration: TimeInterval = 0.3, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.alpha = 1
        }, completion: completion)
    }
}
