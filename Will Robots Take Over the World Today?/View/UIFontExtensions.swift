//
//  UIFontExtensions.swift
//  Will Robots Take Over the World Today?
//
//  Created by Milo Wyner on 3/22/19.
//  Copyright © 2019 Milo Wyner. All rights reserved.
//

import UIKit

extension UIFont {
    
    static var customFont: UIFont = {
        return UIFont(name: "Cabin-Regular", size: 17)!
    }()
    
    static func dynamicCustomFont(for style: UIFont.TextStyle) -> UIFont {
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
        
        /*
         The reason I'm loading the font from a font descriptor instead of just by font name is a
         workaround for a bug (only in this app, and only in iOS 13) where UIFont(name:size:) returns nil
         after the app re-enters the foreground after entering the background.
         
         The workaround is to load the font when the app first launches, then use the font descriptor
         to use the font in different sizes.
         */
        let font = UIFont(descriptor: customFont.fontDescriptor, size: fontSize)
        
        return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
    }
    
}
