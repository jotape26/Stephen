//
//  MainListViewModel.swift
//  Stephen
//
//  Created by João Leite on 30/06/21.
//

import Foundation
import RxCocoa

class MainListViewModel : NSObject, DrinksListViewModelProtocol {
    
    private var cocktailList       : BehaviorRelay<[Cocktail]> = BehaviorRelay(value: [])
    private var requestRelay       : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    private var navigationDelegate : CocktailNavigationDelegate!
    
    init(navigationDelegate: CocktailNavigationDelegate) {
        self.navigationDelegate = navigationDelegate
    }
    
    var drinksCount: Int { requestRelay.value ? 20 : cocktailList.value.count }
    
    var cocktailListDriver: Driver<[Cocktail]> {
        
        Driver.combineLatest(cocktailList.asDriver(), requestRelay.asDriver()) { cocktails, requestStatus in
            return requestStatus ? [] : cocktails
        }
        
    }
    
    var cocktailsList: [Cocktail] {
        get {
            return cocktailList.value
        }
    }
    
    func configureNewCocktails(_ newList: [Cocktail]) {
        cocktailList.accept(newList)
    }
    
    func getCocktail(atIndex ind: Int) -> Cocktail? {
        guard ind >= 0 else { return nil }
        return cocktailList.value.endIndex > ind ? nil : cocktailList.value[ind]
    }
    
    func configureCocktailCell(_ cell: DrinkListPreviewCell, index: Int) {
        guard index <= cocktailList.value.endIndex else { return }
        cell.bind(cocktailList.value[index])
    }
    
    func didSelectIndex(_ index: Int) {
        guard index <= cocktailList.value.endIndex else { return }
        navigationDelegate.didSelected(cocktail: cocktailList.value[index])
    }
    
    func isMakingRequest(_ isMaking: Bool) {
        requestRelay.accept(isMaking)
    }
    
    func getCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        if requestRelay.value {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadCell", for: indexPath) as! LoadingCell
            cell.prepareForReuse()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrinkCell", for: indexPath) as! DrinkListPreviewCell
            cell.bind(cocktailList.value[indexPath.row])
            return cell
        }
    }
    
}
