//
//  DrinkDetailViewModel.swift
//  Stephen
//
//  Created by João Leite on 01/07/21.
//

import Foundation
import RxSwift
import RxCocoa

protocol DrinkDetailViewModelProtocol {
    
    var cocktail : Cocktail { get }
    var cocktailInstructions : [String] { get }
    var cocktailIngredients : [DrinkIngredientInfo] { get }
    
    var dataErrorPublisher : PublishSubject<Void> { get }
    var nameDriver : Driver<String> { get }
    var imageURLDriver : Driver<URL?> { get }
    var drinkTagsDriver : Driver<[String]> { get }
    
    func refreshInformation()
    func getTagItemSize(index: Int) -> CGSize
    
}

class DrinkDetailViewModel : NSObject, DrinkDetailViewModelProtocol {

    private(set) var cocktail : Cocktail
    
    private(set) var tagsSubject : BehaviorRelay<[String]> = BehaviorRelay(value: [])
    private(set) var nameRelay : BehaviorRelay<String> = BehaviorRelay(value: "")
    private(set) var imageRelay : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    
    var cocktailInstructions: [String] {
        get { cocktail.instructions }
    }
    
    var cocktailIngredients: [DrinkIngredientInfo] {
        get { cocktail.ingredients }
    }
    
    var drinkTagsDriver: Driver<[String]> {
        get {
            tagsSubject.asDriver(onErrorJustReturn: [])
        }
    }
    
    var nameDriver: Driver<String> {
        get {
            nameRelay.asDriver()
        }
    }
    
    var imageURLDriver: Driver<URL?> {
        get {
            imageRelay.asDriver()
        }
    }
    
    var dataErrorPublisher: PublishSubject<Void> { PublishSubject() }
    
    init(cocktail c: Cocktail) {
        cocktail = c
    }
    
    func refreshInformation() {
        self.nameRelay.accept(cocktail.name)
        self.imageRelay.accept(cocktail.thumbnailURL)
        self.tagsSubject.accept(cocktail.tags)
    }
    
    func getTagItemSize(index: Int) -> CGSize {
        let item = tagsSubject.value[index]
        let itemSize = item.size(withAttributes: [
            NSAttributedString.Key.font : AppFont.Bold(17).uiFont
        ])
        
        return CGSize(width: itemSize.width * 2, height: 30)
    }
}
