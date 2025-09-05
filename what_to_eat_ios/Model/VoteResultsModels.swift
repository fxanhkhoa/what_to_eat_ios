//
//  VoteResultsModels.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 22/8/25.
//

import Foundation

// MARK: - Enhanced Vote Result Model
struct EnrichedVoteResult: Identifiable {
    let id = UUID()
    let dishVoteItem: DishVoteItem
    let dish: Dish?
    let totalVotes: Int
    let userVotes: Int
    let anonymousVotes: Int
    
    var displayName: String {
        if dishVoteItem.isCustom {
            return dishVoteItem.customTitle ?? "Custom Dish"
        } else if let dish = dish {
            // Try to get localized title, fallback to first available or slug
            let currentLanguage = LocalizationService.shared.currentLanguage.rawValue
            return dish.getTitle(for: currentLanguage) ??
                   dish.title.first?.data ??
                   dish.slug
        } else {
            return dishVoteItem.slug
        }
    }
    
    var displayDescription: String? {
        guard let dish = dish else { return nil }
        let currentLanguage = LocalizationService.shared.currentLanguage.rawValue
        return dish.getShortDescription(for: currentLanguage) ??
               dish.shortDescription.first?.data
    }
    
    var thumbnailURL: String? {
        return dish?.thumbnail
    }
    
    var mealCategories: [String] {
        return dish?.mealCategories ?? []
    }
    
    var tags: [String] {
        return dish?.tags ?? []
    }
}

// MARK: - Original Vote Result Model (kept for compatibility)
struct VoteResult: Identifiable {
    let id = UUID()
    let dishVoteItem: DishVoteItem
    let totalVotes: Int
    let userVotes: Int
    let anonymousVotes: Int
    
    var percentage: Double {
        0.0 // Will be calculated in the view based on max votes
    }
}