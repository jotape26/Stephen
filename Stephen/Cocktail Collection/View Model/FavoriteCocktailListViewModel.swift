//
//  FavoriteCocktailListViewModel.swift
//  Stephen
//
//  Created by João Leite on 04/07/21.
//

import UIKit

protocol FavoriteCocktailManager: NSObject {
    var userDefaults : UserDefaults { get set }
    var viewModelReference : DrinksListViewModelProtocol? { get set }
    
    func saveNewCocktail(_ cocktail: Cocktail)
    func removeCocktail(_ cocktail: Cocktail)
    
    func syncWithViewModel()
    
    func isFavoriteCocktail(id: String) -> Bool
}

class FavoriteCocktailListViewModel : MainListViewModel {
    
    override func getCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoritesCell", for: indexPath) as! FavoriteCocktailsCell
        cell.prepareForReuse()
        return cell
    }
    
}

class FavoriteCocktailBusiness : NSObject, FavoriteCocktailManager {
    
    weak var viewModelReference : DrinksListViewModelProtocol? {
        didSet {
            syncWithViewModel()
        }
    }

    var userDefaults : UserDefaults = UserDefaults.standard
    
    private let kFavoriteDrinksKey = "FavoriteDrinksIDArray"
    
    private var favoriteDrinks : [CocktailModel] {
        get {
            
            if let data = userDefaults.value(forKey: kFavoriteDrinksKey) as? Data,
               let cocktails = try? PropertyListDecoder().decode([CocktailModel].self, from: data) {
                return cocktails
            }
            
            return []
        }
        set {
            userDefaults.set(try? PropertyListEncoder().encode(newValue), forKey: kFavoriteDrinksKey)
        }
    }
    
    func saveNewCocktail(_ cocktail: Cocktail) {
        guard !favoriteDrinks.contains(where: { $0.id == cocktail.id }) else { return }
        
        if let model = cocktail as? CocktailModel {
            favoriteDrinks.append(model)
        }
        
        syncWithViewModel()
    }
    
    func removeCocktail(_ cocktail: Cocktail) {
        if let index = favoriteDrinks.firstIndex(where: { $0.id == cocktail.id }) {
            favoriteDrinks.remove(at: index)
            syncWithViewModel()
        }
    }
    
    func syncWithViewModel() {
        viewModelReference?.configureNewCocktails(favoriteDrinks.map({ $0 }))
    }
    
    func isFavoriteCocktail(id: String) -> Bool {
        return favoriteDrinks.contains(where: { $0.id == id })
    }
    
}
