//
//  AppFont.swift
//  Stephen
//
//  Created by João Leite on 09/07/21.
//

import UIKit
import SwiftUI

enum AppFont {
    case Regular(Int), Bold(Int), Italic(Int)
    
    var uiFont : UIFont {
        get {
            switch self {
            
            case .Regular(let size): return UIFont(name: "LouisGeorgeCafe", size: CGFloat(size))!
            case .Bold(let size): return UIFont(name: "LouisGeorgeCafe-Bold", size: CGFloat(size))!
            case .Italic(let size): return UIFont(name: "LouisGeorgeCafe-Italic", size: CGFloat(size))!
            }
        }
    }
    
    var swiftUiFont : Font {
        get {
            switch self {
            
            case .Regular(let size): return Font.custom("LouisGeorgeCafe", size: CGFloat(size))
            case .Bold(let size): return Font.custom("LouisGeorgeCafe-Bold", size: CGFloat(size))
            case .Italic(let size): return Font.custom("LouisGeorgeCafe-Italic", size: CGFloat(size))
            }
        }
    }
}
