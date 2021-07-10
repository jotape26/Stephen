//
//  CocktailListSectionHeaderCell.swift
//  Stephen
//
//  Created by João Leite on 03/07/21.
//

import UIKit

class CocktailListSectionHeaderCell : UICollectionViewCell {
    
    var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = AppColors.TextColor
        label.numberOfLines = 0
        
        AppFonts(family: .Bold, uiFontStyle: .title1).configure(label)
        
        return label
    }()
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    private func prepare() {
        addSubview(titleLabel)
        constraintToEdges(titleLabel, margins: 10.0)
    }
}
