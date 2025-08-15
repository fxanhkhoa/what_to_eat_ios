//
//  HomeGameSection.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 8/8/25.
//

import SwiftUI

struct GameMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let action: () -> Void
}

struct GameMenuItemView: View {
    let item: GameMenuItem
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: item.action) {
            VStack(spacing: 12) {
                Image(item.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                            .shadow(color: colorScheme == .dark ? Color.black.opacity(0.6) : Color.gray.opacity(0.3), radius: 6, x: 4, y: 4)
                            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.1) : Color.white, radius: 6, x: -4, y: -4)
                    )
                
                Text(LocalizationService.shared.localizedString(for: item.title))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Text(LocalizationService.shared.localizedString(for: item.description))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 36)
            }
            .frame(width: 110, height: 150)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(UIColor.systemGray5) : Color.white)
                    .shadow(color: colorScheme == .dark ? Color.black.opacity(0.5) : Color.gray.opacity(0.2), radius: 8, x: 5, y: 5)
                    .shadow(color: colorScheme == .dark ? Color.white.opacity(0.05) : Color.white, radius: 8, x: -5, y: -5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HomeGameSection: View {
    @State private var showWheelOfFortune = false
    @State private var showFlippingCard = false
    
    var gameItems: [GameMenuItem] {
        [
            GameMenuItem(
                title: "wheel_of_fortune",
                description: "wheel_of_fortune_desc",
                iconName: "wheel_of_fortune_menu",
                action: {
                    showWheelOfFortune = true
                }
            ),
            GameMenuItem(
                title: "flipping_card",
                description: "flipping_card_desc",
                iconName: "flipping_card_menu",
                action: {
                    showFlippingCard = true
                }
            ),
            GameMenuItem(
                title: "vote_game",
                description: "vote_game_desc",
                iconName: "vote_menu",
                action: {
                    print("Vote Game tapped")
                    // Navigation action can be added here
                }
            )
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizationService.shared.localizedString(for: "game_section_title"))
                .font(.headline)
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(gameItems) { item in
                        GameMenuItemView(item: item)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .fullScreenCover(isPresented: $showWheelOfFortune) {
            WheelOfFortune()
        }.fullScreenCover(isPresented: $showFlippingCard) {
            FlippingCard()
        }
        
    }
}

#Preview {
    HomeGameSection()
}
