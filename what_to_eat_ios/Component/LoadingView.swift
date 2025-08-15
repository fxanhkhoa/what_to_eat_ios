//
//  LoadingView.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 15/8/25.
//

import SwiftUI

struct LoadingView: View {
    let localization: LocalizationService
    var title: String?
    var systemImage: String = "arrow.clockwise"
    var imageSize: CGFloat = 40
    var imageColor: Color = Color("PrimaryColor")
    var showAnimation: Bool = true
    
    var body: some View {
        VStack(spacing: 16) {
            if showAnimation {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(imageColor)
            } else {
                Image(systemName: systemImage)
                    .font(.system(size: imageSize))
                    .foregroundColor(imageColor)
            }
            
            Text(title ?? localization.localizedString(for: "loading"))
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// Convenience initializers for common use cases
extension LoadingView {
    init(localization: LocalizationService,
         title: String? = nil,
         systemImage: String = "arrow.clockwise",
         showAnimation: Bool = true) {
        self.localization = localization
        self.title = title
        self.systemImage = systemImage
        self.imageSize = 40
        self.imageColor = Color("PrimaryColor")
        self.showAnimation = showAnimation
    }
    
    // For dishes
    static func forDishes(localization: LocalizationService) -> LoadingView {
        LoadingView(
            localization: localization,
            title: localization.localizedString(for: "loading_dishes"),
            systemImage: "fork.knife",
            showAnimation: true
        )
    }
    
    // For ingredients
    static func forIngredients(localization: LocalizationService) -> LoadingView {
        LoadingView(
            localization: localization,
            title: localization.localizedString(for: "loading_ingredients"),
            systemImage: "leaf.fill",
            showAnimation: true
        )
    }
    
    // For games
    static func forGames(localization: LocalizationService) -> LoadingView {
        LoadingView(
            localization: localization,
            title: localization.localizedString(for: "loading_games"),
            systemImage: "gamecontroller",
            showAnimation: true
        )
    }
    
    // For general data
    static func forData(localization: LocalizationService) -> LoadingView {
        LoadingView(
            localization: localization,
            title: localization.localizedString(for: "loading_data"),
            systemImage: "arrow.clockwise",
            showAnimation: true
        )
    }
    
    // For network requests
    static func forNetwork(localization: LocalizationService) -> LoadingView {
        LoadingView(
            localization: localization,
            title: localization.localizedString(for: "connecting"),
            systemImage: "wifi",
            showAnimation: true
        )
    }
    
    // For search operations
    static func forSearch(localization: LocalizationService) -> LoadingView {
        LoadingView(
            localization: localization,
            title: localization.localizedString(for: "searching"),
            systemImage: "magnifyingglass",
            showAnimation: true
        )
    }
}

#Preview {
    VStack(spacing: 30) {
        LoadingView(localization: LocalizationService.shared)
        
        LoadingView.forDishes(localization: LocalizationService.shared)
        
        LoadingView.forIngredients(localization: LocalizationService.shared)
        
        LoadingView.forGames(localization: LocalizationService.shared)
        
        LoadingView.forNetwork(localization: LocalizationService.shared)
    }
}
