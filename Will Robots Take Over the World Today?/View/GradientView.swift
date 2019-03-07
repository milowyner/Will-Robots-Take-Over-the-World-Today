//
//  GradientView.swift
//  Will Robots Take Over the World Today?
//
//  Created by Milo Wyner on 2/24/19.
//  Copyright © 2019 Milo Wyner. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var firstColor: UIColor? {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var secondColor: UIColor? {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        if let firstColor = firstColor, let secondColor = secondColor {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.bounds
            gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
            self.layer.addSublayer(gradientLayer)
        } else {
            self.backgroundColor = firstColor ?? secondColor
        }
    }
    
    
}
