//
//  LoadingView.swift
//  Stephen
//
//  Created by João Leite on 30/06/21.
//

import UIKit

class LoadingView : UIView {
    
    enum Glass : Int {
        case Beer, Cocktail, Coffee, Wine
        
        var image : UIImage? {
            switch self {
            case .Beer:
                return UIImage(named: "beer")
            case .Cocktail:
                return UIImage(named: "cocktail")
            case .Coffee:
                return UIImage(named: "coffee")
            case .Wine:
                return UIImage(named: "wine")
            }
        }
        
        var animation : UIView.AnimationOptions {
            switch self {
            case .Beer:
                return .transitionFlipFromLeft
            case .Cocktail:
                return .transitionFlipFromTop
            case .Coffee:
                return .transitionFlipFromRight
            case .Wine:
                return .transitionFlipFromBottom
            }
        }
    }
    
    let imageView : UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .center
        img.tintColor = AppColors.TextColor
        return img
    }()
    
    private var isAnimating : Bool = false {
        didSet {
            if isAnimating {
                changeImage(to: .Beer)
            }
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = AppColors.TextColor.withAlphaComponent(0.2)
        
        addSubview(imageView)
        addConstraints([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override func draw(_ rect: CGRect) {
        isAnimating = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeImage(to: Glass) {
        
        UIView.transition(with: imageView,
                          duration: 0.75,
                          options: to.animation,
                          animations: { self.imageView.image = to.image },
                          completion: { _ in
                            if self.isAnimating {
                                self.changeImage(to: Glass(rawValue: to.rawValue + 1) ?? .Beer)
                            }
                          })
    }
}
