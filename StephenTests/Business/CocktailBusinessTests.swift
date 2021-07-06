//
//  CocktailBusinessTests.swift
//  StephenTests
//
//  Created by João Leite on 29/06/21.
//

import XCTest
@testable import Stephen

class CocktailBusinessTests: XCTestCase {
    
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
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCocktailListDownload() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let business : CocktailBusinessProtocol = CocktailBusiness()
        
        business.fetchMainCocktails { result in
            XCTAssert(result.cocktails.isEmpty == false)
        }
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
