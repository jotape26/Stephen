//
//  CocktailTagCell.swift
//  Stephen
//
//  Created by João Leite on 03/07/21.
//

import UIKit

class CocktailTagCell : UICollectionViewCell {
    
    var tagLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = AppColors.WineRed.uiColor
        label.textAlignment = .center
        AppFonts(family: .Bold, uiFontStyle: .body).configure(label)
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        contentView.layer.cornerRadius = 10.0
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white.withAlphaComponent(0.7)
        
        if tagLabel.superview == nil {
            
            contentView.addSubview(tagLabel)
            contentView.addConstraints([
                tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                tagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                tagLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
                tagLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
    }
    
}
