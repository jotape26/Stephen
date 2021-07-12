//
//  CocktailBusiness.swift
//  Stephen
//
//  Created by João Leite on 29/06/21.
//

import Foundation
import Moya

typealias IngredientResult = (ingredients: [Ingredient], error: NetworkError?)
typealias CocktailResult = (cocktails: [Cocktail], error: NetworkError?)

protocol CocktailBusinessProtocol {
    func searchCocktail(byName name: String, callback: @escaping (CocktailResult) -> ())
    func searchCocktail(byIngredient ingredient: Ingredient)

    func fetchCocktailDetails(_ cocktail: Cocktail, callback: @escaping (NetworkError?) -> ())
    func fetchCocktail(byID id: String, callback: @escaping (NetworkError?) -> ())
    func fetchMainCocktails(callback: @escaping (CocktailResult) -> ())
    func fetchRandomCocktail(callback: @escaping (CocktailResult) -> ())
}

class CocktailBusiness : CocktailBusinessProtocol {
    
    internal var provider : MoyaProvider<CocktailService> = MoyaProvider()

    func searchCocktail(byName name: String, callback: @escaping (CocktailResult) -> ()) {
        provider.request(.searchCocktailByName(name)) { result in
            do {
                
                let cocktailDrinks = try self.drinksResponseParser(result)
                callback((cocktailDrinks, nil))
                
            } catch let error {
                
                if let error = error as? NetworkError {
                    callback(([], error))
                } else {
                    callback(([], NetworkError.RequestError(error.localizedDescription)))
                }
                
            }
        }
    }
    
    func searchCocktail(byIngredient ingredient: Ingredient) {
        provider.request(.searchCocktailByIngredient(ingredient.name)) { result in
            
        }
    }
    
    func fetchCocktailDetails(_ cocktail: Cocktail, callback: @escaping (NetworkError?) -> ()) {
        guard cocktail.cocktailNeedsDetails else { callback(nil); return }
        
        provider.request(.fetchCocktailByID(cocktail.id)) { result in
            
            do {
                
                let result = try result.get()
                let serializedResult = try JSONSerialization.jsonObject(with: result.data, options: .mutableContainers)
                
                guard let dictionary = serializedResult as? [String : Any] else {
                    throw NetworkError.WrongFormat
                }

                if let drinkArray = dictionary["drinks"] as? [[String : Any]], let drinkInfo = drinkArray.first {
                    
                    cocktail.registerDetails(data: drinkInfo)
                    callback(nil)
                } else {
                    throw NetworkError.WrongFormat
                }

            } catch let error {
                callback(NetworkError.RequestError(error.localizedDescription))
            }
        }
    }
    
    func fetchCocktail(byID id: String, callback: @escaping (NetworkError?) -> ()) {
        provider.request(.fetchCocktailByID(id)) { result in
            
        }
    }
    
    func fetchMainCocktails(callback: @escaping (CocktailResult) -> ()) {
        provider.request(.fetchMainCocktails) { result in
            
            
            do {
                
                let cocktailDrinks = try self.drinksResponseParser(result)
                callback((cocktailDrinks, nil))
                
            } catch let error {
                
                if let error = error as? NetworkError {
                    callback(([], error))
                } else {
                    callback(([], NetworkError.RequestError(error.localizedDescription)))
                }
                
            }
        }
    }
    
    func fetchRandomCocktail(callback: @escaping (CocktailResult) -> ()) {
        provider.request(.fetchRandomCocktail) { result in
            do {
                
                if let randomCocktail = try self.drinksResponseParser(result).first {
                    callback(([randomCocktail], nil))
                } else {
                    throw NetworkError.WrongFormat
                }

            } catch let error {
                
                if let error = error as? NetworkError {
                    callback(([], error))
                } else {
                    callback(([], NetworkError.RequestError(error.localizedDescription)))
                }
                
            }
        }
    }
    
    private func drinksResponseParser(_ response: Result<Response, MoyaError>) throws -> [Cocktail] {
        let result = try response.get()
        let serializedResult = try JSONSerialization.jsonObject(with: result.data, options: .mutableContainers)
        
        guard let dictionary = serializedResult as? [String : Any] else {
            throw NetworkError.WrongFormat
        }

        let drinkArray = dictionary["drinks"] as? [[String : Any]] ?? []
        
        return drinkArray.compactMap({ CocktailModel.createFromJSON(JSON: $0) })
    }
    
}

enum NetworkError: Error {
    case WrongFormat
    case RequestError(String)
    
    var description : String {
        switch self {
        case .WrongFormat: return "Returned data came in wrong format."
        case .RequestError: return "Request returned status different than 200 range."
        }
    }
}
