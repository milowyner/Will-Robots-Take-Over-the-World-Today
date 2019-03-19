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
        let fontName = "Cabin-Regular"
        var fontSize: CGFloat
        
        switch style {
        case .body:
            fontSize = 17
        case .title1:
            fontSize = 60
        default:
            fatalError("Unknown font style")
        }
        
        guard let customFont = UIFont(name: fontName, size: fontSize) else {
            fatalError("Unknown font name")
        }
        
        self.font = UIFontMetrics(forTextStyle: style).scaledFont(for: customFont)
        self.adjustsFontForContentSizeCategory = true
    }
}
