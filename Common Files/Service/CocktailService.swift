//
//  CocktailService.swift
//  Stephen
//
//  Created by João Leite on 29/06/21.
//

import Foundation
import Moya
import Alamofire

enum CocktailService {
    //Search Endpoints
    case searchCocktailByName(_ name: String)
    case searchCocktailByIngredient(_ ingredient: String)
    
    //Detail Endpoins
    case fetchCocktailByID(_ id: String)
    case fetchMainCocktails
    case fetchRandomCocktail
}

extension CocktailService : TargetType {
    var baseURL: URL { URL(string: "https://www.thecocktaildb.com/api/json/v1/1/")! }
    
    var path: String {
        switch self {
        case .searchCocktailByName(_), .searchCocktailByIngredient(_):
            return "search.php"
            
        case .fetchCocktailByID(_):
            return "lookup.php"
            
        case .fetchMainCocktails:
            return "filter.php"
            
        case .fetchRandomCocktail:
            return "random.php"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        switch self {
        case .searchCocktailByName(let name):
            return "{'s': '\(name)'}".data(using: .utf8)!
            
        case .searchCocktailByIngredient(let ingredient):
            return "{'i': '\(ingredient)'}".data(using: .utf8)!
            
        case .fetchCocktailByID(let id):
            return "{'i': '\(id)'}".data(using: .utf8)!
            
        case .fetchMainCocktails:
            return "{'a' : 'Alcoholic'}".data(using: .utf8)!
            
        case .fetchRandomCocktail:
            return Data()
        }
    }
    
    var task: Task {
        switch self {
        case .fetchRandomCocktail:
            return .requestPlain
            
        case .fetchMainCocktails:
            return .requestParameters(parameters: ["a" : "Alcoholic"], encoding: URLEncoding.queryString)
            
        case .searchCocktailByName(let name):
            return .requestParameters(parameters: ["s" : name], encoding: URLEncoding.queryString)
            
        case .searchCocktailByIngredient(let ingredient):
            return .requestParameters(parameters: ["i" : ingredient], encoding: URLEncoding.queryString)
            
        case .fetchCocktailByID(let id):
            return .requestParameters(parameters: ["i" : id], encoding: URLEncoding.queryString)
            
        }
        
    }
    
    var headers: [String : String]? { return nil }
    
    
}

