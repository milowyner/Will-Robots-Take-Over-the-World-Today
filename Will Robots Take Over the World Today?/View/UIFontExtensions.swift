//
//  UIFontExtensions.swift
//  Will Robots Take Over the World Today?
//
//  Created by Milo Wyner on 3/22/19.
//  Copyright © 2019 Milo Wyner. All rights reserved.
//

import UIKit

extension UIFont {
    static func dynamicCustomFont(for style: UIFont.TextStyle) -> UIFont {
        let fontName = "Cabin-Regular"
        var fontSize: CGFloat
        
        switch style {
        case .body:
            fontSize = 17
        case .title1:
            fontSize = 110
        case .title2:
            fontSize = 70
        case .title3:
            fontSize = 28
        case .headline:
            fontSize = 16
        case .subheadline:
            fontSize = 13
        case .caption1:
            fontSize = 13
        default:
            fatalError("Unknown font style")
        }
        
        guard let customFont = UIFont(name: fontName, size: fontSize) else {
            print("ERROR: Custom font \"\(fontName)\" not found. Using system font instead.")
            return UIFont.preferredFont(forTextStyle: style)
        }
        
        return UIFontMetrics(forTextStyle: style).scaledFont(for: customFont)
    }
}
