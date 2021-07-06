//
//  DrinksListViewModelProtocol.swift
//  Stephen
//
//  Created by João Leite on 30/06/21.
//

import Foundation
import RxCocoa

protocol DrinksListViewModelProtocol: NSObject {
    var cocktailsList : [Cocktail] { get }
    
    var cocktailListDriver : Driver<[Cocktail]> { get }
    var drinksCount : Int { get }
    
    func configureNewCocktails(_ newList : [Cocktail])
    func isMakingRequest(_ isMaking: Bool)
    
    func getCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
    func didSelectIndex(_ index: Int)
}
