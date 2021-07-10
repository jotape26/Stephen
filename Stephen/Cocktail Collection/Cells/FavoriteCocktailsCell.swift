//
//  FavoriteCocktailsCell.swift
//  Stephen
//
//  Created by João Leite on 03/07/21.
//

import UIKit
import RxSwift

class FavoriteCocktailsCell : UICollectionViewCell {

    private var disposeBag : DisposeBag = DisposeBag()
    
    private var noFavoritesView : UIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.TextColor.withAlphaComponent(0.2)
        view.layer.cornerRadius = 10.0
        
        let contentStack = UIStackView()
        contentStack.spacing = 5.0
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .center
        
        view.addSubview(contentStack)
        
        let noFavoriteTextLabel = UILabel()
        noFavoriteTextLabel.translatesAutoresizingMaskIntoConstraints = false
        noFavoriteTextLabel.textColor = AppColors.TextColor
        noFavoriteTextLabel.numberOfLines = 0
        noFavoriteTextLabel.text = "You haven't favorited any cocktails.\nLet's find you a new signature drink?"
        noFavoriteTextLabel.textAlignment = .center
        AppFonts(family: .Regular, uiFontStyle: .headline).configure(noFavoriteTextLabel)
        
        let starImage = UIImageView(image: UIImage(systemName: "star.circle"))
        starImage.widthAnchor.constraint(equalTo: starImage.heightAnchor).isActive = true
        starImage.translatesAutoresizingMaskIntoConstraints = false
        starImage.tintColor = noFavoriteTextLabel.textColor
        
        contentStack.addArrangedSubview(starImage)
        contentStack.addArrangedSubview(noFavoriteTextLabel)
        
        NSLayoutConstraint.activate([
            contentStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0),
            
            starImage.heightAnchor.constraint(equalToConstant: 60.0),
            starImage.widthAnchor.constraint(equalToConstant: 60.0),
        ])
        return view
        
    }()
    
    private lazy var favoritesCollection : UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 120, height: 120)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(DrinkListPreviewCell.self, forCellWithReuseIdentifier: "DrinkCell")
        collection.delegate = self
        collection.backgroundColor = .clear
        return collection
    }()
    
    func bind(_ viewModel: DrinksListViewModelProtocol) {
        disposeBag = DisposeBag()
        
        viewModel.cocktailListDriver
            .drive(onNext: { [self] cocktailList in
                
                var viewToFocus  : UIView?
                var viewToRemove : UIView?
                
                if cocktailList.isEmpty {
                    if noFavoritesView.superview == nil {
                        viewToFocus = noFavoritesView
                    }
                    if favoritesCollection.superview != nil {
                        viewToRemove = favoritesCollection
                    }
                    
                } else {
                    if favoritesCollection.superview == nil {
                        viewToFocus = favoritesCollection
                    }
                    if noFavoritesView.superview != nil {
                        viewToRemove = noFavoritesView
                    }
                }
                
                guard let viewToFocus = viewToFocus else { return }
                
                if let viewToRemove = viewToRemove {
                    viewToRemove.removeFromSuperview()
                }
                
                contentView.addSubview(viewToFocus)
                NSLayoutConstraint.activate([
                    viewToFocus.topAnchor.constraint(equalTo: contentView.topAnchor),
                    viewToFocus.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    viewToFocus.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                    viewToFocus.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                    
                ])
                
                
            })
            .disposed(by: disposeBag)
        
        viewModel.cocktailListDriver
            .drive(favoritesCollection
                    .rx
                    .items(cellIdentifier: "DrinkCell", cellType: DrinkListPreviewCell.self)) { _, cocktail, cell in
                cell.bind(cocktail)
            }
            .disposed(by: disposeBag)
        
        favoritesCollection
            .rx
            .itemSelected
            .asDriver()
            .drive(onNext: {
                viewModel.didSelectIndex($0.row)
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIDevice.orientationDidChangeNotification)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { _ in
                self.favoritesCollection.collectionViewLayout.invalidateLayout()
            })
            .disposed(by: disposeBag)
    }
}

extension FavoriteCocktailsCell : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
}
