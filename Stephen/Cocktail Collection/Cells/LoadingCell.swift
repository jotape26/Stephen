//
//  LoadingCell.swift
//  Stephen
//
//  Created by João Leite on 30/06/21.
//

import UIKit

class LoadingCell : UICollectionViewCell {
    var loadingView : LoadingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        if loadingView == nil {
            loadingView = LoadingView()
            loadingView.translatesAutoresizingMaskIntoConstraints = false

            contentView.layer.cornerRadius = 10.0
            contentView.clipsToBounds = true
            contentView.addSubview(loadingView)
            contentView.addConstraints([
                loadingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                loadingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                loadingView.topAnchor.constraint(equalTo: contentView.topAnchor),
                loadingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
    }
}
