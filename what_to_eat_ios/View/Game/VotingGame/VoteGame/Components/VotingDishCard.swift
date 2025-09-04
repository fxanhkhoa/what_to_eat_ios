//
//  VotingDishCard.swift
//  what_to_eat_ios
//
//  Created by System on 30/8/25.
//

import SwiftUI

struct VotingDishCard: View {
    let item: DishVoteItem
    let dish: Dish?
    let isSelected: Bool
    let onTap: () -> Void
    
    var localization = LocalizationService.shared
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                if let thumbnail = dish?.thumbnail, !thumbnail.isEmpty {
                    AsyncImage(url: URL(string: thumbnail)) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color(.systemGray5)
                    }
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                } else {
                    Image(systemName: item.isCustom ? "person.crop.circle.badge.plus" : "fork.knife")
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : Color("PrimaryColor"))
                }
                Text(MultiLanguage.getLocalizedData(
                    from: dish?.title ?? [],
                    for: localization.currentLanguage.rawValue) ?? localization.localizedString(for: "unknown_dish"))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 120)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color("PrimaryColor") : Color(.systemGray6))
                    .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? Color("PrimaryColor").opacity(0.3) : Color.black.opacity(0.1),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible())
    ], spacing: 12) {
        VotingDishCard(
            item: DishVoteItem(
                slug: "pho-bo",
                customTitle: "",
                voteUser: [],
                voteAnonymous: [],
                isCustom: false
            ),
            dish: nil,
            isSelected: false,
            onTap: {}
        )
        
        VotingDishCard(
            item: DishVoteItem(
                slug: "custom-dish",
                customTitle: "My Special Dish",
                voteUser: [],
                voteAnonymous: [],
                isCustom: true
            ),
            dish: nil,
            isSelected: true,
            onTap: {}
        )
    }
    .padding()
}
