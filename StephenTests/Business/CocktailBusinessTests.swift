//
//  CocktailBusinessTests.swift
//  StephenTests
//
//  Created by João Leite on 29/06/21.
//

import XCTest
@testable import Stephen

class CocktailBusinessTests: XCTestCase {

    var business : CocktailBusinessProtocol!
    
    override func setUp() {
        super.setUp()
        business = CocktailBusiness()
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
        
        business.fetchMainCocktails { result in
            XCTAssert(result.cocktails.isEmpty == false)
        }
    }
    
}
