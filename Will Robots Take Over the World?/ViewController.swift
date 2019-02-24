//
//  ViewController.swift
//  Will Robots Take Over the World?
//
//  Created by Milo Wyner on 2/24/19.
//  Copyright © 2019 Milo Wyner. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Layer for applying gradient
    var gradientLayer: CAGradientLayer!
    
    // Light and dark colors used for background gradient
    var lightColor = UIColor(named: "clearDayLight")!.cgColor
    var darkColor = UIColor(named: "clearDayDark")!.cgColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply gradient to background
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [lightColor, darkColor]
        self.view.layer.addSublayer(gradientLayer)
    }


}

