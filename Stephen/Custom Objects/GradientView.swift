//
//  GradientView.swift
//  Stephen
//
//  Created by João Leite on 01/07/21.
//

import UIKit

class GradientView : UIView {
    
    var startColor : CGColor!
    var endColor   : CGColor!
    
    init(startColor s: CGColor, endColor e: CGColor) {
        super.init(frame: CGRect.zero)
        startColor = s
        endColor = e
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        layer.sublayers?.remove(at: 0)
        setGradientBackground(startColor: startColor,
                              endColor: endColor)
    }
}
