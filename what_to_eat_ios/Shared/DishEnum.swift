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
              let level = DifficultyLevel(rawValue: string.lowercased()) else {
            return .easy
        }
        return level
    }
}
