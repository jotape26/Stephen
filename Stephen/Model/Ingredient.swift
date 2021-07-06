//
//  Ingredient.swift
//  Stephen
//
//  Created by João Leite on 29/06/21.
//

import Foundation

protocol Ingredient {
    var id          : String { get }
    var name        : String { get }
    var description : String { get }
}

class IngredientModel : Ingredient {
    private(set) var id          : String
    private(set) var name        : String
    private(set) var description : String
    
    private init(id: String, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
    
    static func createFromJSON(JSON data: [String : Any]) -> IngredientModel? {
        
        guard let idIng = data["idIngredient"] as? String,
              let nmIng = data["strIngredient"] as? String,
              let dsIng = data["strDescription"] as? String else { return nil }
        
        return IngredientModel(id: idIng, name: nmIng, description: dsIng)
    }
}
