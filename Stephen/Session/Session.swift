//
//  Session.swift
//  Stephen
//
//  Created by João Leite on 04/07/21.
//

import Foundation
import RxSwift
import RxCocoa

class Session {
    static var current : Session = Session()
    
    
    
    
    private var favoriteCocktailsRelay : BehaviorRelay<[Cocktail]> = BehaviorRelay(value: [])
    
    var favoritesDrinksDriver : Driver<[Cocktail]> {
        get {
            favoriteCocktailsRelay.asDriver()
        }
    }
    
    
    
}
