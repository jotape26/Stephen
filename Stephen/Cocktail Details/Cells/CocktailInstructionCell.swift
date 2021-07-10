//
//  CocktailInstructionCell.swift
//  Stephen
//
//  Created by João Leite on 03/07/21.
//

import UIKit

class CocktailInstructionCell : UITableViewCell {
    
    enum InstructionStep {
         case Start, Middle, End, Unique
        
        func getImage() -> UIImage? {
            switch self {
            case .Start: return UIImage(named: "circle-start")
            case .Middle: return UIImage(named: "circle-middle")
            case .End: return UIImage(named: "circle-end")
            case .Unique: return UIImage(named: "circle-unique")
            }
        }
    }
    
    private var stackView : UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        return stack
    }()
    
    private lazy var instructionDescriptionLabel : UILabel! = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = AppColors.TextColor
        AppFonts(family: .Regular).configure(label)
        
        return label
    }()
    
    private lazy var instructionStepLabel : UILabel! = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = AppColors.TextColor
        label.textAlignment = .center
        AppFonts(family: .Regular).configure(label)
        
        return label
    }()
    
    private lazy var instructionImage : UIImageView! = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = AppColors.TextColor
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        contentView.addSubview(stackView)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        let stepImageHolderView = UIView()
        stepImageHolderView.translatesAutoresizingMaskIntoConstraints = false
        stepImageHolderView.backgroundColor = .clear
        stepImageHolderView.addSubview(instructionImage)
        stepImageHolderView.addSubview(instructionStepLabel)
        
        NSLayoutConstraint.activate([
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            instructionImage.topAnchor.constraint(equalTo: stepImageHolderView.topAnchor),
            instructionImage.bottomAnchor.constraint(equalTo: stepImageHolderView.bottomAnchor),
            instructionImage.leadingAnchor.constraint(equalTo: stepImageHolderView.leadingAnchor),
            instructionImage.trailingAnchor.constraint(equalTo: stepImageHolderView.trailingAnchor),
            
            instructionStepLabel.topAnchor.constraint(equalTo: stepImageHolderView.topAnchor),
            instructionStepLabel.bottomAnchor.constraint(equalTo: stepImageHolderView.bottomAnchor),
            instructionStepLabel.leadingAnchor.constraint(equalTo: stepImageHolderView.leadingAnchor),
            instructionStepLabel.trailingAnchor.constraint(equalTo: stepImageHolderView.trailingAnchor),
            
            stepImageHolderView.heightAnchor.constraint(equalToConstant: 70),
            stepImageHolderView.widthAnchor.constraint(equalToConstant: 70),
        ])
        
        stackView.addArrangedSubview(stepImageHolderView)
        stackView.addArrangedSubview(instructionDescriptionLabel)
    }
    
    func fillInfo(instruction: String, step: InstructionStep, index: Int) {
        instructionDescriptionLabel.text = instruction
        instructionStepLabel.text = "\(index + 1)"
        instructionImage.image = step.getImage()
    }
}
