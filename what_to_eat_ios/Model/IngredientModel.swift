//
//  IngredientModel.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 12/8/25.
//

import Foundation

struct Ingredient: Codable, Identifiable {
    // BaseModel properties
    let id: String
    let deleted: Bool
    let createdAt: String?
    let updatedAt: String?
    let createdBy: String?
    let updatedBy: String?
    let deletedBy: String?
    let deletedAt: String?
    
    // Ingredient-specific properties
    let slug: String
    let title: [MultiLanguage<String>]
    let measure: String
    let calories: Double?
    let carbohydrate: Double?
    let fat: Double?
    let ingredientCategory: [String]
    let weight: Double?
    let protein: Double?
    let cholesterol: Double?
    let sodium: Double?
    let images: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case deleted, createdAt, updatedAt, createdBy, updatedBy, deletedBy, deletedAt
        case slug, title, measure, calories, carbohydrate, fat, ingredientCategory
        case weight, protein, cholesterol, sodium, images
    }
}

struct QueryIngredientDto: Codable {
    let page: Int?
    let limit: Int?
    let keyword: String?
    let ingredientCategory: [String]?
}

struct CreateIngredientDto: Codable {
    let slug: String
    let title: [MultiLanguage<String>]
    let measure: String?
    let calories: Double?
    let carbohydrate: Double?
    let fat: Double?
    let ingredientCategory: [String]
    let weight: Double?
    let protein: Double?
    let cholesterol: Double?
    let sodium: Double?
    let images: [String]
}

struct UpdateIngredientDto: Codable {
    let id: String
    let slug: String
    let title: [MultiLanguage<String>]
    let measure: String?
    let calories: Double?
    let carbohydrate: Double?
    let fat: Double?
    let ingredientCategory: [String]
    let weight: Double?
    let protein: Double?
    let cholesterol: Double?
    let sodium: Double?
    let images: [String]
}
