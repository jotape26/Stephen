//
//  AppColors.swift
//  Stephen
//
//  Created by João Leite on 09/07/21.
//

import UIKit
import SwiftUI

struct ColorMapping {
    
    enum Scale {
        case Standard, AppleScale
    }
    
    var red   : CGFloat
    var green : CGFloat
    var blue  : CGFloat
    var alpha : CGFloat
    var scale : Scale
    
    init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1, s: Scale = .AppleScale) {
        guard r <= 255 && r >= 0 else { fatalError() }
        guard g <= 255 && g >= 0 else { fatalError() }
        guard b <= 255 && b >= 0 else { fatalError() }
        guard a <= 1 && a >= 0 else { fatalError() }
        
        red = r
        green = g
        blue = b
        alpha = a
        scale = s
    }
    
    var uiColor : UIColor {
        if scale == .AppleScale {
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
        }
    }
    
    var swiftUiColor : Color {
        return (Color(uiColor))
    }
    
}

struct AppColors {
    static var WineRed = ColorMapping(r: 67, g: 0, b: 0, s: .Standard)
    
    static var TextColor = UIColor(named: "TextColor")!
    static var BackgroundColor = UIColor(named: "BackgroundColor")!
}
