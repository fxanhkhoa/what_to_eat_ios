//
//  EmptyStateView.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 15/8/25.
//

import SwiftUI

struct EmptyStateView: View {
    let localization: LocalizationService
    var title: String?
    var subtitle: String?
    var systemImage: String = "leaf.fill"
    var imageSize: CGFloat = 50
    var imageColor: Color = .gray
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: imageSize))
                .foregroundColor(imageColor)
            
            Text(title ?? localization.localizedString(for: "no_items_found"))
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text(subtitle ?? localization.localizedString(for: "try_adjusting_search_criteria"))
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// Convenience initializers for common use cases
extension EmptyStateView {
    init(localization: LocalizationService,
         title: String? = nil,
         subtitle: String? = nil,
         systemImage: String = "leaf.fill") {
        self.localization = localization
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.imageSize = 50
        self.imageColor = .gray
    }
    
    // For dishes
    static func forDishes(localization: LocalizationService) -> EmptyStateView {
        EmptyStateView(
            localization: localization,
            title: localization.localizedString(for: "no_dishes_found"),
            subtitle: localization.localizedString(for: "try_adjusting_dish_filters"),
            systemImage: "fork.knife"
        )
    }
    
    // For ingredients
    static func forIngredients(localization: LocalizationService) -> EmptyStateView {
        EmptyStateView(
            localization: localization,
            title: localization.localizedString(for: "no_ingredients_found"),
            subtitle: localization.localizedString(for: "try_adjusting_search"),
            systemImage: "leaf.fill"
        )
    }
    
    // For games
    static func forGames(localization: LocalizationService) -> EmptyStateView {
        EmptyStateView(
            localization: localization,
            title: localization.localizedString(for: "no_games_available"),
            subtitle: localization.localizedString(for: "check_back_later"),
            systemImage: "gamecontroller"
        )
    }
    
    // For network errors
    static func forNetworkError(localization: LocalizationService) -> EmptyStateView {
        EmptyStateView(
            localization: localization,
            title: localization.localizedString(for: "connection_error"),
            subtitle: localization.localizedString(for: "check_connection_try_again"),
            systemImage: "wifi.slash"
        )
    }
}

#Preview {
    VStack(spacing: 30) {
        EmptyStateView(localization: LocalizationService.shared)
        
        EmptyStateView.forDishes(localization: LocalizationService.shared)
        
        EmptyStateView.forIngredients(localization: LocalizationService.shared)
        
        EmptyStateView.forNetworkError(localization: LocalizationService.shared)
    }
}
