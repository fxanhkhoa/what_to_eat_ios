//
//  FlippingCard.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 15/8/25.
//

import SwiftUI
import Combine

struct FlippingCard: View {
    @StateObject private var viewModel = FlippingCardViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    let localization = LocalizationService.shared
    
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
                
                if viewModel.isLoading {
                    LoadingView.forDishes(localization: localization)
                } else if viewModel.dishes.isEmpty {
                    EmptyStateView.forDishes(localization: localization)
                } else {
                    ScrollView {
                        // Header
                        GameHeaderView(localization: localization)
                        
                        // Game board
                        GameBoardView(
                            cards: viewModel.cards,
                            onCardTapped: viewModel.cardTapped,
                            localization: localization
                        )
                        
                        // Action button
                        GameActionsView(
                            gameState: viewModel.gameState,
                            onNewGame: viewModel.startNewGame,
                            localization: localization
                        )
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
                
                // Game completion overlay
                if viewModel.gameState == .completed, let selectedDish = viewModel.selectedDish {
                    DishRevealView(
                        dish: selectedDish,
                        onNewGame: viewModel.startNewGame,
                        onClose: { viewModel.gameState = .playing },
                        localization: localization
                    )
                }
            }
            .navigationTitle(localization.localizedString(for: "flipping_card"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.startNewGame) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadDishes()
        }
    }
}

// MARK: - Game Header View
struct GameHeaderView: View {
    let localization: LocalizationService
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 40))
                .foregroundColor(Color("PrimaryColor"))
            
            Text(localization.localizedString(for: "pick_a_card"))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(localization.localizedString(for: "tap_card_to_reveal_dish"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
}

// MARK: - Game Board View
struct GameBoardView: View {
    let cards: [GameCard]
    let onCardTapped: (GameCard) -> Void
    let localization: LocalizationService
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(cards) { card in
                DishCardView(
                    card: card,
                    onTapped: { onCardTapped(card) },
                    localization: localization
                )
            }
        }
        .padding()
    }
}

// MARK: - Dish Card View
struct DishCardView: View {
    let card: GameCard
    let onTapped: () -> Void
    let localization: LocalizationService
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTapped) {
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardBackgroundColor)
                    .overlay(
                        // Add gradient overlay for unflipped cards
                        Group {
                            if !card.isFlipped {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color("PrimaryColor").opacity(0.8),
                                        Color("PrimaryColor").opacity(0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    )
                    .frame(height: 140)
                    .shadow(radius: card.isFlipped ? 8 : 4)
                
                if card.isFlipped {
                    // Front side - show dish
                    VStack(spacing: 8) {
                        AsyncImage(url: URL(string: card.dish.thumbnail ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .overlay(
                                    Image(systemName: "fork.knife")
                                        .foregroundColor(.gray)
                                        .font(.title2)
                                )
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Text(dishTitle)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                    .padding(12)
                } else {
                    // Back side - show card back
                    VStack(spacing: 8) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .scaleEffect(x: -1)
                        
                        Text(localization.localizedString(for: "mystery_dish"))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .scaleEffect(x: -1)
                    }
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .rotation3DEffect(
                .degrees(card.isFlipped ? 0 : 180),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(.easeInOut(duration: 0.8), value: card.isFlipped)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(card.isFlipped)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {}, onPressingChanged: { pressing in
            isPressed = pressing
        })
    }
    
    private var cardBackgroundColor: Color {
        if card.isFlipped {
            return Color(.systemBackground)
        } else {
            return colorScheme == .dark ? Color(.systemGray4) : Color(.systemGray5)
        }
    }
    
    private var dishTitle: String {
        return card.dish.title.first(where: { $0.lang == localization.currentLanguage.rawValue })?.data ??
               card.dish.title.first?.data ??
               localization.localizedString(for: "unknown_dish")
    }
}

// MARK: - Game Actions View
struct GameActionsView: View {
    let gameState: GameState
    let onNewGame: () -> Void
    let localization: LocalizationService
    
    var body: some View {
        if gameState == .playing {
            Text(localization.localizedString(for: "choose_your_destiny"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .italic()
        } else {
            Button(action: onNewGame) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text(localization.localizedString(for: "new_game"))
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(Color("PrimaryColor"))
                .foregroundColor(.white)
                .cornerRadius(25)
                .font(.headline)
            }
        }
    }
}

// MARK: - Dish Reveal View
struct DishRevealView: View {
    let dish: Dish
    let onNewGame: () -> Void
    let onClose: () -> Void
    let localization: LocalizationService
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Celebration
                VStack(spacing: 16) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                        .scaleEffect(1.2)
                    
                    Text(localization.localizedString(for: "dish_revealed"))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(localization.localizedString(for: "your_random_dish_is"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Dish Details
                VStack(spacing: 16) {
                    AsyncImage(url: URL(string: dish.thumbnail ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "fork.knife")
                                    .foregroundColor(.gray)
                                    .font(.title)
                            )
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    NavigationLink(destination: DishDetailView(dish: dish)) {
                        Text(dishTitle)
                            .overlay {
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "#F3A446"), Color(hex: "#A06235")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .mask(
                                    Text(dishTitle)
                                )
                            }
                            .fontWeight(.bold)
                            .font(.headline)
                    }
                    
                    if let description = dishDescription {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                }
                
                // Buttons
                HStack(spacing: 16) {
                    Button(action: onClose) {
                        Text(localization.localizedString(for: "close"))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray4))
                            .foregroundColor(.primary)
                            .cornerRadius(25)
                    }
                    
                    Button(action: onNewGame) {
                        Text(localization.localizedString(for: "try_again"))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color("PrimaryColor"))
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                    .shadow(radius: 20)
            )
            .padding(.horizontal, 40)
        }
    }
    
    private var dishTitle: String {
        return dish.title.first(where: { $0.lang == localization.currentLanguage.rawValue })?.data ??
               dish.title.first?.data ??
               localization.localizedString(for: "unknown_dish")
    }
    
    private var dishDescription: String? {
        return dish.shortDescription.first(where: { $0.lang == localization.currentLanguage.rawValue })?.data ??
               dish.shortDescription.first?.data
    }
}

#Preview {
    FlippingCard()
}
