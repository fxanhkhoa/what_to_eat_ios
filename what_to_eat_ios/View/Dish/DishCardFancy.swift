//
//  DishCardFancy.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 7/8/25.
//

import SwiftUI
import Kingfisher

struct DishCardFancy: View {
    let dish: Dish
    @Environment(\.colorScheme) var colorScheme
    
    func getDifficultyColor() -> Color {
        if let level = DifficultyLevel(rawValue: dish.difficultLevel ?? "") {
            return level.color
        }
        return Color.gray // Default color if difficulty level is not recognized
    }
    
    // Slice title to 20 words max with ellipsis if exceeded
    func slicedTitle() -> String {
        let title = dish.getTitle(for: LocalizationService.shared.currentLanguage.rawValue) ?? ""
        let words = title.split(separator: " ")
        
        if words.count <= 7 {
            return title
        } else {
            return words.prefix(7).joined(separator: " ") + "..."
        }
    }
    
    // Slice short description to 100 words max with ellipsis if exceeded
    func slicedDescription() -> String {
        let desc = dish.getShortDescription(for: LocalizationService.shared.currentLanguage.rawValue) ?? ""
        let words = desc.split(separator: " ")
        
        if words.count <= 20 {
            return desc
        } else {
            return words.prefix(20).joined(separator: " ") + "..."
        }
    }
    
    // Get a random background image name
    func getRandomBackgroundImage() -> String {
        let backgrounds = ["food-card-bg-1", "food-card-bg-2", "food-card-bg-3", "food-card-bg-4"]
        return backgrounds.randomElement() ?? "food-card-bg-1"
    }
    
    var body: some View {
        ZStack {
            // Random background image
            Image(getRandomBackgroundImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.25)
                .frame(height: 120)
        
            // Main content with neumorphic effect
            HStack(spacing: 16) {
                ZStack {
                    KFImage(URL(string: dish.thumbnail ?? ""))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150) // Increased size
                        .cornerRadius(.infinity)
                        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.5) : Color.gray.opacity(0.2), radius: 4, x: 2, y: 2)
                        .offset(x: -20, y: 0) // Offset to left
                }
                .frame(width: 120, height: 120)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(slicedTitle())
                        .overlay {
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#F3A446"), Color(hex: "#A06235")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .mask(
                                Text(slicedTitle())
                            )
                        }
                        .fontWeight(.bold)
                        .font(.headline)
                    
                    Text(slicedDescription())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(){
                        VStack (alignment: .center) {
                            HStack{
                                Image("preparation_time")
                                    .resizable()
                                    .frame(width: 14, height: 14)
                                Text(LocalizationService.shared.localizedString(for: "preparation"))
                                    .overlay {
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(hex: "#F3A446"), Color(hex: "#A06235")]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .mask(
                                            Text(LocalizationService.shared.localizedString(for: "preparation"))
                                        )
                                    }
                                    .font(.caption)
                                
                            }
                            Text("\(dish.preparationTime ?? 0) \(LocalizationService.shared.localizedString(for: "mins"))")
                                .font(.caption)
                            
                        }
                        Spacer()
                        VStack (alignment: .center){
                            HStack{
                                Image("cooking_time")
                                    .resizable()
                                    .frame(width: 14, height: 14)
                                Text(LocalizationService.shared.localizedString(for: "cooking"))
                                    .overlay {
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(hex: "#F3A446"), Color(hex: "#A06235")]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .mask(
                                            Text(LocalizationService.shared.localizedString(for: "cooking"))
                                        )
                                    }
                                    .font(.caption)
                            }
                            Text("\(dish.cookingTime ?? 0) \(LocalizationService.shared.localizedString(for: "mins"))")
                                .font(.caption)
                        }
                        Spacer()
                        VStack{
                            if (dish.difficultLevel == DifficultyLevel.easy.rawValue) {
                                Image("easy")
                                    .resizable()
                                    .frame(width: 14, height: 14)
                            }
                            if (dish.difficultLevel == DifficultyLevel.medium.rawValue) {
                                Image("medium")
                                    .resizable()
                                    .frame(width: 14, height: 14)
                            }
                            if (dish.difficultLevel == DifficultyLevel.hard.rawValue) {
                                Image("hard")
                                    .resizable()
                                    .frame(width: 14, height: 14)
                            }
                            
                            if (dish.difficultLevel != nil) {
                                HStack {
                                    LocalizedText(dish.difficultLevel ?? "")
                                        .font(.caption)
                                        .foregroundColor(getDifficultyColor())
                                        .padding(.horizontal, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white)
                                                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.2), radius: 1, x: -1, y: -1)
                                                .shadow(color: colorScheme == .dark ? Color.black.opacity(0.7) : Color.black.opacity(0.1), radius: 1, x: 1, y: 1)
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.trailing, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                .shadow(color: colorScheme == .dark ? Color.black.opacity(0.6) : Color.gray.opacity(0.3), radius: 8, x: 5, y: 5)
                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.1) : Color.white, radius: 8, x: -5, y: -5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(height: 80)
    }
}

#Preview {
    DishCardFancy(dish: SampleData.sampleDish)
        .frame(width: 350)
        .padding()
}
