//
//  Cocktail.swift
//  Stephen
//
//  Created by João Leite on 03/07/21.
//

import Foundation

protocol Cocktail: Codable {
    var id           : String { get }
    var name         : String { get }
    var thumbnailURL : URL? { get }
    
    var ingredients  : [DrinkIngredientInfo] { get }
    var instructions : [String] { get }
    var tags         : [String] { get }
    
    var cocktailNeedsDetails : Bool { get }
    func registerDetails(data: [String : Any])
}

struct DrinkIngredientInfo {
    var name : String
    var quantity : String?
}

class CocktailModel : Cocktail {

    private(set) var id           : String
    private(set) var name         : String
    private(set) var thumbnailURL : URL?
    
    var ingredients: [DrinkIngredientInfo] = []
    var instructions: [String] = []
    var tags: [String] = []
    
    var cocktailNeedsDetails: Bool {
        get {
            return ingredients.isEmpty || instructions.isEmpty
        }
    }
    
    init(id: String, name: String, thumbURL: URL?) {
        self.id = id
        self.name = name
        self.thumbnailURL = thumbURL
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, thumbnailURL
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.id = try container.decode(String.self, forKey: .id)
        self.thumbnailURL = try container.decodeIfPresent(URL.self, forKey: .thumbnailURL)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.name, forKey: .name)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.thumbnailURL, forKey: .thumbnailURL)
        
    }
    
    static func createFromJSON(JSON data: [String : Any]) -> CocktailModel? {
        
        guard let idDrk = data["idDrink"] as? String,
              let nmDrk = data["strDrink"] as? String else { return nil }
        
        return CocktailModel(id: idDrk, name: nmDrk, thumbURL: URL(string: data["strDrinkThumb"] as? String ?? ""))
    }
    
    func registerDetails(data: [String : Any]) {

        if let instructionString = data["strInstructions"] as? String {
            instructions = instructionString.components(separatedBy: ". ")
        }
        
        for i in 1...15 {
            
            if let ingredient = data["strIngredient\(i)"] as? String {
                
                ingredients.append(DrinkIngredientInfo(name: ingredient,
                                                       quantity: data["strMeasure\(i)"] as? String))
                
            } else {
                break
            }
            
        }
        
        if let cocktailType = data["strAlcoholic"] as? String {
            tags.append(cocktailType)
        }
        
        if let cocktailCategory = data["strCategory"] as? String {
            tags.append(cocktailCategory)
        }
        
        if let ibaRating = data["strIBA"] as? String {
            tags.append("IBA: \(ibaRating)")
        }
        
    }
    
    
}
