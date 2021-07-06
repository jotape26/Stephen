//
//  UIViewController+Extensions.swift
//  Stephen
//
//  Created by João Leite on 03/07/21.
//

import UIKit
import SwiftMessages

class BaseViewController : UIViewController {
    
    func showLoading() {
        let loadingView = LoadingView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.tag = 97654
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10.0
        
        view.addSubview(loadingView)
        
        view.addConstraints([
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.heightAnchor.constraint(equalToConstant: 100.0),
            loadingView.widthAnchor.constraint(equalToConstant: 100.0),
        ])
    }
    
    func hideLoading() {
        if let loadingView = view.subviews.first(where: { $0.tag == 97654 }) {
            loadingView.removeFromSuperview()
        }
    }
    
    func showErrorMessage(title: String, message: String, closeButtonText: String = "Close",
                          callback: @escaping()->()) {
        var config = SwiftMessages.Config()

        // Slide up from the bottom.
        config.presentationStyle = .bottom

        // Display in a window at the specified window level.
        config.presentationContext = .window(windowLevel: .statusBar)
        config.dimMode = .blur(style: .dark, alpha: 0.7, interactive: true)
        config.duration = .forever
        
        let view = MessageView.viewFromNib(layout: .cardView)
        
        // Theme message elements with the warning style.
        view.configureTheme(.error)
        
        view.configureContent(title: title, body: message, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: closeButtonText) { _ in
            
            DispatchQueue.main.async {
                SwiftMessages.hide()
            }
            
            callback()
        }
        // Add a drop shadow.
        view.configureDropShadow()
        
        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        
        // Increase the external margin around the card. In general, the effect of this setting
        // depends on how the given layout is constrained to the layout margins.
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        // Reduce the corner radius (applicable to layouts featuring rounded corners).
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        
        // Show the message.
        DispatchQueue.main.async {
            SwiftMessages.show(config: config, view: view)
        }
    }
}
