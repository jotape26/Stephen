//
//  RandomDrink.swift
//  RandomDrink
//
//  Created by João Leite on 09/07/21.
//

import WidgetKit
import SwiftUI
import Intents
import Kingfisher

struct DefaultDrinks {
    static var Margarita = CocktailModel(id: "11007",
                                         name: "Margarita",
                                         thumbURL: nil)
}
struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(cocktail: DefaultDrinks.Margarita)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(cocktail: DefaultDrinks.Margarita)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        var entries: [SimpleEntry] = []
        
        let business = CocktailBusiness()
        let imageRequestGroup = DispatchGroup()
        business.fetchRandomCocktail { result in
            imageRequestGroup.enter()
            
            if let randomElement = result.cocktails.randomElement() {
                self.downloadImage(url: randomElement.thumbnailURL!) { newImage in
                    entries.append(SimpleEntry(cocktail: randomElement, image: newImage))
                    
                    imageRequestGroup.leave()
                }
                
            } else {
                entries.append(SimpleEntry(cocktail: DefaultDrinks.Margarita))
                imageRequestGroup.leave()
            }
            
            imageRequestGroup.notify(queue: .main) {
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
            
        }
        
        
    }
    
    func downloadImage(url: URL, completion: @escaping (UIImage?)->()) {
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            completion(UIImage(data: data))
        }
        
        dataTask.resume()
    }
    
}

struct SimpleEntry: TimelineEntry {
    let cocktail: Cocktail
    var image : UIImage?
    let date: Date = Date()
}

struct RandomDrinkEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack(alignment: .leading) {
            Color(AppColors.WineRed.uiColor)
            
            VStack(alignment: .leading) {
                
                Text(entry.cocktail.name)
                    .configure(AppFonts(family: .Regular, swiftUIFontStyle: .body))
                    .foregroundColor(.white)
                    .lineLimit(50)
                
                if let img = entry.image {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .cornerRadius(10.0)
                } else {
                    Image("margarita-preview")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .cornerRadius(10.0)
                }
                
                
            }.padding(.all, 10.0)
            
            
        }.widgetURL({ () -> URL? in
            var urlComponents = URLComponents()
            urlComponents.scheme = "stephenDrinks"
            urlComponents.host = "openWidget"
            urlComponents.queryItems = [URLQueryItem(name: "id", value: "\(entry.cocktail.id)"),
                                        URLQueryItem(name: "name", value: "\(entry.cocktail.name)")]

            if let url = entry.cocktail.thumbnailURL {
                urlComponents.queryItems?.append(URLQueryItem(name: "thumbnailURL", value: "\(url)"))
            }
            
            return urlComponents.url
        }())
    }
}

@main
struct RandomDrink: Widget {
    let kind: String = "RandomDrink"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RandomDrinkEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Random Cocktail Suggestions")
        .description("Get cocktails suggestions on your home screen. You never know when you are going to find your next favorite drink!")
    }
}

struct RandomDrink_Previews: PreviewProvider {
    
    static var previews: some View {
        RandomDrinkEntryView(entry: SimpleEntry(cocktail: DefaultDrinks.Margarita))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
