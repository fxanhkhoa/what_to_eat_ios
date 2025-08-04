//
//  DishCard.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 3/8/25.
//

import SwiftUI
import Kingfisher

struct DishCard: View {
    let dish: Dish
    var preferredLanguage: String = "en" // Default language
    
    var title: String {
        // Find the title in the preferred language or default to the first one
        dish.title.first(where: { $0.lang == preferredLanguage })?.data ??
        dish.title.first?.data ?? "Untitled"
    }
    
    var description: String {
        // Find the description in the preferred language or default to the first one
        dish.shortDescription.first(where: { $0.lang == preferredLanguage })?.data ??
        dish.shortDescription.first?.data ?? "No description available"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // Display thumbnail image or a placeholder
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
                    .frame(width: 160, height: 120)
                    .cornerRadius(10)
                    .clipped()
            } else {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(width: 160, height: 120)
                    .cornerRadius(10)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Display cooking and preparation time if available
            if dish.cookingTime != nil || dish.preparationTime != nil {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatTotalTime())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 2)
            }
        }
        .frame(width: 160)
    }
    
    // Helper method to format the total cooking and preparation time
    private func formatTotalTime() -> String {
        let prepTime = dish.preparationTime ?? 0
        let cookTime = dish.cookingTime ?? 0
        let totalMinutes = prepTime + cookTime
        
        if totalMinutes == 0 {
            return "Time N/A"
        } else if totalMinutes < 60 {
            return "\(totalMinutes) min"
        } else {
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            return "\(hours)h \(minutes)m"
        }
    }
}

#Preview {
    // Create a sample dish for preview
    let sampleMultiLang = [MultiLanguage(lang: "en", data: "Sample Dish")]
    let sampleDesc = [MultiLanguage(lang: "en", data: "This is a sample dish description for preview purposes.")]
    
    let sampleDish = Dish(
        id: "1",
        deleted: false,
        createdAt: "",
        updatedAt: "",
        createdBy: nil,
        updatedBy: nil,
        deletedBy: nil,
        deletedAt: nil,
        slug: "sample-dish",
        title: sampleMultiLang,
        shortDescription: sampleDesc,
        content: sampleDesc,
        tags: ["sample"],
        preparationTime: 15,
        cookingTime: 25,
        difficultLevel: "easy",
        mealCategories: ["lunch"],
        ingredientCategories: [],
        thumbnail: nil,
        videos: [],
        ingredients: [],
        relatedDishes: [],
        labels: []
    )
    
    return DishCard(dish: sampleDish)
}
