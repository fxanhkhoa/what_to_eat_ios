//
//  DishEnum.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 7/8/25.
//

import SwiftUI

/// Represents dish difficulty levels throughout the app
enum DifficultyLevel: String, Codable, CaseIterable, Identifiable {
    case easy = "EASY"
    case medium = "MEDIUM"
    case hard = "HARD"
    
    var id: String {
        self.rawValue
    }
    
    /// Display name for the difficulty level
    var displayName: String {
        switch self {
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
        }
    }
    
    /// Localization key for the difficulty level
    var localizationKey: String {
        switch self {
        case .easy:
            return "difficulty_easy"
        case .medium:
            return "difficulty_medium"
        case .hard:
            return "difficulty_hard"
        }
    }
    
    /// Color associated with the difficulty level
    var color: Color {
        switch self {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
    
    /// System image name for the difficulty level
    var iconName: String {
        switch self {
        case .easy:
            return "tortoise.fill"
        case .medium:
            return "hare.fill"
        case .hard:
            return "bolt.fill"
        }
    }
    
    var svgIconName: String {
        switch self {
        case .easy:
            return "easy"
        case .medium:
            return "medium"
        case .hard:
            return "hard"
        }
    }
    
    /// Get DifficultyLevel from a string, defaulting to .easy if invalid
    static func from(_ string: String?) -> DifficultyLevel {
        guard let string = string,
              let level = DifficultyLevel(rawValue: string) else {
            return .easy
        }
        return level
    }
}

/// Represents meal categories throughout the app
enum MealCategory: String, Codable, CaseIterable, Identifiable {
    case breakfast = "BREAKFAST"
    case lunch = "LUNCH"
    case brunch = "BRUNCH"
    case dinner = "DINNER"
    case burger = "BURGER"
    case salad = "SALAD"
    case soup = "SOUP"
    case appetizer = "APPETIZER"
    case dessert = "DESSERT"
    case hotpot = "HOTPOT"
    case northVN = "NORTH_VN"
    case centralVN = "CENTRAL_VN"
    case southVN = "SOUTH_VN"
    case sweetSoup = "SWEET_SOUP"
    case vitamin = "VITAMIN"
    
    var id: String {
        self.rawValue
    }
    
    /// Display name for the meal category
    var displayName: String {
        switch self {
        case .breakfast:
            return "Breakfast"
        case .lunch:
            return "Lunch"
        case .brunch:
            return "Brunch"
        case .dinner:
            return "Dinner"
        case .burger:
            return "Burger"
        case .salad:
            return "Salad"
        case .soup:
            return "Soup"
        case .appetizer:
            return "Appetizer"
        case .dessert:
            return "Dessert"
        case .hotpot:
            return "Hotpot"
        case .northVN:
            return "North Vietnam"
        case .centralVN:
            return "Central Vietnam"
        case .southVN:
            return "South Vietnam"
        case .sweetSoup:
            return "Sweet Soup"
        case .vitamin:
            return "Vitamin"
        }
    }
    
    /// Localization key for the meal category
    var localizationKey: String {
        switch self {
        case .breakfast:
            return "category_breakfast"
        case .lunch:
            return "category_lunch"
        case .brunch:
            return "category_brunch"
        case .dinner:
            return "category_dinner"
        case .burger:
            return "category_burger"
        case .salad:
            return "category_salad"
        case .soup:
            return "category_soup"
        case .appetizer:
            return "category_appetizer"
        case .dessert:
            return "category_dessert"
        case .hotpot:
            return "category_hotpot"
        case .northVN:
            return "category_north_vn"
        case .centralVN:
            return "category_central_vn"
        case .southVN:
            return "category_south_vn"
        case .sweetSoup:
            return "category_sweet_soup"
        case .vitamin:
            return "category_vitamin"
        }
    }
    
    /// Get MealCategory from a string, defaulting to .breakfast if invalid
    static func from(_ string: String?) -> MealCategory {
        guard let string = string,
              let category = MealCategory(rawValue: string.uppercased()) else {
            return .breakfast
        }
        return category
    }
}
