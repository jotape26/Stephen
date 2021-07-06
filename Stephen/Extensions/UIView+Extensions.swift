//
//  UIView+Extensions.swift
//  Stephen
//
//  Created by João Leite on 01/07/21.
//

import UIKit

extension UIView {
    func setGradientBackground(startColor : CGColor, endColor: CGColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [startColor, endColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = bounds
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func constraintToEdges(_ view: UIView, margins: CGFloat = 0.0) {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor, constant: margins),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margins),
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margins),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margins)
        ])

    }
}
