//
//  DrinkListPreviewCell.swift
//  Stephen
//
//  Created by João Leite on 30/06/21.
//

import UIKit
import Kingfisher

class DrinkListPreviewCell : UICollectionViewCell {
    
    var previewImage : UIImageView!
    var cocktailNameLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        
        self.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.clipsToBounds = true
        
        if previewImage == nil {
            previewImage = UIImageView()
            previewImage.translatesAutoresizingMaskIntoConstraints = false

            contentView.addSubview(previewImage)
            contentView.addConstraints([
                previewImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                previewImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                previewImage.topAnchor.constraint(equalTo: contentView.topAnchor),
                previewImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
        
        if cocktailNameLabel == nil {
            cocktailNameLabel = UILabel()
            cocktailNameLabel.font = AppFont.Bold(23).uiFont
            cocktailNameLabel.translatesAutoresizingMaskIntoConstraints = false
            cocktailNameLabel.textColor = .white
            cocktailNameLabel.numberOfLines = 0
            
            contentView.addSubview(cocktailNameLabel)
            contentView.addConstraints([
                cocktailNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5.0),
                cocktailNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5.0),
                cocktailNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5.0)
            ])
        }

    }
    
    func bind(_ cocktail: Cocktail) {
        prepareForReuse()
        
        cocktailNameLabel.text = cocktail.name
        
        if let url = cocktail.thumbnailURL {
            previewImage.kf.setImage(with: url)
        }
    }
    
}
