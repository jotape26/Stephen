//
//  AppFont.swift
//  Stephen
//
//  Created by João Leite on 09/07/21.
//

import UIKit
import SwiftUI

struct AppFonts {
    
    
    private let kRegularFont = "LouisGeorgeCafe"
    private let kBoldFont = "LouisGeorgeCafe-Bold"
    private let kItalicFont = "LouisGeorgeCafe-Italic"
    
    enum FontFamily {
        case Regular, Bold, Italic
    }
    
    private var family : FontFamily!
    private var size : CGFloat = 17
    
    private var uiFontStyle : UIFont.TextStyle!
    private var swiftUIFontStyle : Font.TextStyle!
    
    init(family: FontFamily,
         uiFontStyle: UIFont.TextStyle = .body,
         swiftUIFontStyle : Font.TextStyle = .body) {
        
        self.size = 17.0
        self.family = family
        self.uiFontStyle = uiFontStyle
        self.swiftUIFontStyle = swiftUIFontStyle
    }
    
    init(size: Int, family: FontFamily) {
        self.init(family: family, uiFontStyle: .body, swiftUIFontStyle: .body)
        self.size = CGFloat(size)
    }
    
    var uiFont : UIFont {
        get {
            switch family {
            
            case .Regular:
                
                return UIFontMetrics(forTextStyle: uiFontStyle)
                    .scaledFont(for: UIFont(name: kRegularFont, size: CGFloat(size))!)
                
            case .Bold:
                
                return UIFontMetrics(forTextStyle: uiFontStyle)
                    .scaledFont(for: UIFont(name: kBoldFont, size: CGFloat(size))!)
                
            case .Italic:
                return UIFontMetrics(forTextStyle: uiFontStyle)
                    .scaledFont(for: UIFont(name: kItalicFont, size: CGFloat(size))!)
                
            case .none:
                fatalError()
            }
        }
    }
    
    func configure(_ label: UILabel) {
        label.font = uiFont
        label.adjustsFontForContentSizeCategory = true
    }
    
    
    
    var swiftUiFont : Font {
        get {
            switch family {
            
            case .Regular:
                
                return Font.custom(kRegularFont,
                            size: CGFloat(size),
                            relativeTo: swiftUIFontStyle)
                
            case .Bold:
                
                return Font.custom(kBoldFont,
                            size: CGFloat(size),
                            relativeTo: swiftUIFontStyle)
                
            case .Italic:
                
                return Font.custom(kItalicFont,
                            size: CGFloat(size),
                            relativeTo: swiftUIFontStyle)
                
            case .none:
                fatalError()
                
            }
        }
    }
    
}

extension Text {
    func configure(_ font: AppFonts) -> Text {
        return self.font(font.swiftUiFont)
    }
}
