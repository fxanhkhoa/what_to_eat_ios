//
//  DishRow.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 3/8/25.
//

import SwiftUI
import Kingfisher

struct DishRow: View {
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
        HStack(spacing: 15) {
            // Display thumbnail image or a placeholder
            if let thumbnailUrl = dish.thumbnail, !thumbnailUrl.isEmpty {
                KFImage(URL(string: thumbnailUrl))
                    .resizable()
                    .placeholder {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "fork.knife")
                                    .foregroundColor(.gray)
                            )
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 60)
                    .cornerRadius(8)
                    .clipped()
            } else {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(width: 80, height: 60)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Add cooking/prep time info if available
                if dish.cookingTime != nil || dish.preparationTime != nil {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(formatTime())
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
    
    // Helper method to format the cooking and preparation time
    private func formatTime() -> String {
        let prepTime = dish.preparationTime ?? 0
        let cookTime = dish.cookingTime ?? 0
        let totalMinutes = prepTime + cookTime
        
        if totalMinutes == 0 {
            return ""
        } else if totalMinutes < 60 {
            return "\(totalMinutes) min"
        } else {
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            if minutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(minutes)m"
            }
        }
    }
}

#Preview {
    // Create a sample dish for preview
    let sampleMultiLang = [MultiLanguage(lang: "en", data: "Thai Green Curry")]
    let sampleDesc = [MultiLanguage(lang: "en", data: "Authentic Thai curry with coconut milk, vegetables, and your choice of protein.")]
    
    let sampleDish = Dish(
        id: "1",
        deleted: false,
        createdAt: "",
        updatedAt: "",
        createdBy: nil,
        updatedBy: nil,
        deletedBy: nil,
        deletedAt: nil,
        slug: "thai-green-curry",
        title: sampleMultiLang,
        shortDescription: sampleDesc,
        content: sampleDesc,
        tags: ["thai", "curry", "spicy"],
        preparationTime: 15,
        cookingTime: 25,
        difficultLevel: "medium",
        mealCategories: ["dinner", "lunch"],
        ingredientCategories: [],
        thumbnail: nil,
        videos: [],
        ingredients: [],
        relatedDishes: [],
        labels: []
    )
    
    return DishRow(dish: sampleDish)
}
