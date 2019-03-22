//
//  UILabelExtensions.swift
//  Will Robots Take Over the World Today?
//
//  Created by Milo Wyner on 3/19/19.
//  Copyright © 2019 Milo Wyner. All rights reserved.
//

import UIKit

extension UILabel {
    func setDynamicCustomFont(for style: UIFont.TextStyle) {
        self.font = UIFont.dynamicCustomFont(for: style)
        self.adjustsFontForContentSizeCategory = true
    }
}
