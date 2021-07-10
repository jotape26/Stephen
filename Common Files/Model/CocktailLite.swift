//
//  CocktailLite.swift
//  Stephen
//
//  Created by João Leite on 09/07/21.
//

import Foundation

class CocktailLite: Codable {
    var id: String
    var name: String
    var thumbnailURL: URL?
    
    init(id: String, name: String, thumbURL: URL?) {
        self.id = id
        self.name = name
        self.thumbnailURL = thumbURL
    }
    
    func mapToModel() -> Cocktail {
        return CocktailModel.mapFromLite(self)
    }
}
