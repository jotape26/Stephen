//
//  FavoriteCocktailTests.swift
//  StephenTests
//
//  Created by João Leite on 06/07/21.
//

import XCTest
@testable import Stephen

class FavoriteCocktailTests: XCTestCase {
    
    var userDefaults: UserDefaults!
    let userDefaultsSuiteName = "TestDefaults"
    
    var navigationDelegate : CocktailNavigationDelegate!
    var manager   : FavoriteCocktailManager!
    var viewModel : DrinksListViewModelProtocol!
    
    override func setUp() {
        super.setUp()
        UserDefaults().removePersistentDomain(forName: userDefaultsSuiteName)
        userDefaults = UserDefaults(suiteName: userDefaultsSuiteName)
        
        navigationDelegate = MainAppNavigationController(rootViewController: UIViewController())
        manager = FavoriteCocktailBusiness()
        manager.userDefaults = userDefaults!
        viewModel = MainListViewModel(navigationDelegate: navigationDelegate)
    }
    
    func testRetrievingFavoritesEmpty() throws {
        
        manager.viewModelReference = viewModel
        manager.syncWithViewModel()
        
        XCTAssert(viewModel.cocktailsList.isEmpty)
        
    }
    
    func testRetrievingFavorites() throws {
        manager.viewModelReference = viewModel
        manager.saveNewCocktail(CocktailModel.mapFromLite(CocktailLite(id: "0", name: "", thumbURL: nil)))
        XCTAssert(viewModel.cocktailsList.isEmpty == false)
    }
    
}
