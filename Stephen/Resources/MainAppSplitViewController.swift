//
//  MainAppSplitViewController.swift
//  Stephen
//
//  Created by João Leite on 30/06/21.
//

import UIKit

protocol CocktailNavigationDelegate {
    func didSelected(cocktail c: Cocktail)
    func goBack()
}

class MainAppNavigationController: UINavigationController {
    
    private var cocktailBusiness : CocktailBusinessProtocol = CocktailBusiness()
    private var favoriteBusiness : FavoriteCocktailManager = FavoriteCocktailBusiness()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = AppColors.WineRed.uiColor
        
        setViewControllers([DrinkListViewController(navigationDelegate: self,
                                                    business: cocktailBusiness,
                                                    favorite: favoriteBusiness)], animated: true)
    }
    
}

extension MainAppNavigationController : CocktailNavigationDelegate {
    func didSelected(cocktail c: Cocktail) {
        pushViewController(DrinkDetailViewController(navigationDelegate: self,
                                                     cocktail: c,
                                                     businessProtocol: cocktailBusiness,
                                                     favoriteProtocol: favoriteBusiness), animated: true)
    }
    
    func goBack() {
        popViewController(animated: true)
    }
}
