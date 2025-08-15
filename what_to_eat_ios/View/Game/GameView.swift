//
//  GameView.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 2/8/25.
//

import SwiftUI

struct GameView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedGame: GameMenuItem?
    @State private var showWheelOfFortune = false
    @State private var showFlippingCard = false
    let localization = LocalizationService.shared
    
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
                    // Navigation to vote game
                }
            )
        ]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground),
                        colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        headerSection
                        
                        // Games Grid
                        gamesGridSection
                        
                        // Featured Section (if needed for future games)
                        featuredSection
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented: $showWheelOfFortune) {
            WheelOfFortune()
        }
        .fullScreenCover(isPresented: $showFlippingCard) {
            FlippingCard()
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#F3A446"))
                .padding(.bottom, 8)
            
            Text(localization.localizedString(for: "game_section_title"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(localization.localizedString(for: "game_section_subtitle"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.bottom, 20)
    }
    
    private var gamesGridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 20) {
            ForEach(gameItems) { item in
                GameCardView(item: item, localization: localization)
            }
        }
    }
    
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(localization.localizedString(for: "featured_games"))
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            // Placeholder for featured content
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                .frame(height: 120)
                .overlay(
                    VStack {
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundColor(.yellow)
                        Text(localization.localizedString(for: "coming_soon"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                )
        }
        .padding(.top, 20)
    }
}

struct GameCardView: View {
    let item: GameMenuItem
    let localization: LocalizationService
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    var body: some View {
        Button(action: item.action) {
            VStack(spacing: 16) {
                // Icon Container
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#F3A446").opacity(0.8),
                                    Color(hex: "#A06235").opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(
                            color: colorScheme == .dark ? Color.black.opacity(0.6) : Color.gray.opacity(0.3),
                            radius: 8,
                            x: 4,
                            y: 4
                        )
                    
                    Image(item.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                }
                
                // Text Content
                VStack(spacing: 8) {
                    Text(localization.localizedString(for: item.title))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(localization.localizedString(for: item.description))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Play Button
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title3)
                        .foregroundColor(Color(hex: "#F3A446"))
                    
                    Text(localization.localizedString(for: "play_now"))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "#F3A446"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(hex: "#F3A446").opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: "#F3A446").opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(.systemGray5) : Color.white)
                    .shadow(
                        color: colorScheme == .dark ? Color.black.opacity(0.4) : Color.gray.opacity(0.2),
                        radius: isPressed ? 5 : 10,
                        x: isPressed ? 2 : 5,
                        y: isPressed ? 2 : 5
                    )
                    .shadow(
                        color: colorScheme == .dark ? Color.white.opacity(0.05) : Color.white,
                        radius: isPressed ? 5 : 10,
                        x: isPressed ? -2 : -5,
                        y: isPressed ? -2 : -5
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {}, onPressingChanged: { pressing in
            isPressed = pressing
        })
    }
}

#Preview {
    GameView()
        .environmentObject(ThemeManager())
}
