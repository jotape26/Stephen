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
    static var Margarita = CocktailLite(id: "11007",
                                        name: "Margarita",
                                        thumbURL: nil)
}
struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(cocktail: DefaultDrinks.Margarita, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(cocktail: DefaultDrinks.Margarita, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        var entries: [SimpleEntry] = []

        let business = CocktailBusiness()
        let imageRequestGroup = DispatchGroup()
        business.fetchMainCocktails { result in
            imageRequestGroup.enter()
            
            if let randomElement = result.cocktails.randomElement() {
                self.downloadImage(url: randomElement.thumbnailURL!) { newImage in
                    entries.append(SimpleEntry(cocktail: randomElement.mapToLite(), image: newImage, configuration: configuration))
                    
                    imageRequestGroup.leave()
                }
                
            } else {
                entries.append(SimpleEntry(cocktail: DefaultDrinks.Margarita, configuration: configuration))
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
    let cocktail: CocktailLite
    var image : UIImage?
    let date: Date = Date()
    let configuration: ConfigurationIntent
}

struct RandomDrinkEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack(alignment: .leading) {
            Color(AppColors.WineRed.uiColor)
            
            VStack(alignment: .leading) {
                
                Text("Check out:\n\(entry.cocktail.name)")
                    .foregroundColor(.white)
                    .lineLimit(50)
                    .font(AppFont.Regular(15).swiftUiFont)
                
                if let img = entry.image {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .cornerRadius(10.0)
                } else {
                    Image("margarita-preview")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .cornerRadius(10.0)
                }
            }.padding(.all, 10.0)
        }
    }
}

@main
struct RandomDrink: Widget {
    let kind: String = "RandomDrink"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            RandomDrinkEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Random Cocktail Suggestions")
        .description("Get cocktails suggestions on your home screen. You never know when you are going to find your next favorite drink!")
    }
}

struct RandomDrink_Previews: PreviewProvider {
    
    static var previews: some View {
        RandomDrinkEntryView(entry: SimpleEntry(cocktail: DefaultDrinks.Margarita, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
