//
//  HomeDishCard.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 5/8/25.
//

import SwiftUI
import Kingfisher

struct HomeDishCard: View {
    let dish: Dish
    let height: CGFloat
    
    init(dish: Dish, height: CGFloat = 160) {
        self.dish = dish
        self.height = height
    }
    
    // Add observer for language changes
    @ObservedObject private var localization = LocalizationObserver()
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let thumbnailUrl = dish.thumbnail, !thumbnailUrl.isEmpty {
                KFImage(URL(string: thumbnailUrl))
                    .resizable()
                    .placeholder {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "fork.knife")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width - 32, height: height)
                    .cornerRadius(10)
                    .clipped()
            } else {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(width: UIScreen.main.bounds.width - 32, height: height)
                    .cornerRadius(10)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            
            // Dark gradient overlay for text
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.black.opacity(0.7),
                        Color.black.opacity(0.3),
                        Color.clear
                    ]
                ),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 80)
            .cornerRadius(10)
            .padding(.top, 80)
            
            // Dish title
            VStack(alignment: .leading, spacing: 4) {
                if let dishTitle = dish.title.first(where: { $0.lang == localization.currentLanguage.rawValue }) {
                    
                    Text(dishTitle.data)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    LocalizedText("untitled")
                }
                if let description = dish.shortDescription.first(where: { $0.lang == localization.currentLanguage.rawValue }) {
                    Text(description.data)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                } else {
                    LocalizedText("untitled")
                }
            }
            .padding([.bottom, .leading], 12)
        }
    }
}
