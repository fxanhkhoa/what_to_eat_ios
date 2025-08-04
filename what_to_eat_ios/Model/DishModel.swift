//
//  Dish.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 3/8/25.
//

import Foundation

struct IngredientsInDish: Codable {
    let quantity: Double
    let slug: String
    let note: String
    let ingredientId: String
}

struct Dish: Codable, Identifiable {
    // BaseModel properties
    let id: String
    let deleted: Bool
    let createdAt: String?  // Made optional
    let updatedAt: String?  // Made optional
    let createdBy: String?
    let updatedBy: String?
    let deletedBy: String?
    let deletedAt: String?
    
    // Dish-specific properties
    let slug: String
    let title: [MultiLanguage<String>]
    let shortDescription: [MultiLanguage<String>]
    let content: [MultiLanguage<String>]
    let tags: [String]
    let preparationTime: Int?
    let cookingTime: Int?
    let difficultLevel: String?
    let mealCategories: [String]
    let ingredientCategories: [String]
    let thumbnail: String?
    let videos: [String]
    let ingredients: [IngredientsInDish]
    let relatedDishes: [String]?
    let labels: [String]?  // Changed to optional array
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case deleted, createdAt, updatedAt, createdBy, updatedBy, deletedBy, deletedAt
        case slug, title, shortDescription, content, tags, preparationTime, cookingTime
        case difficultLevel, mealCategories, ingredientCategories, thumbnail, videos
        case ingredients, relatedDishes, labels
    }
    
    // Custom init to provide default values for potentially null arrays
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode required fields
        id = try container.decode(String.self, forKey: .id)
        deleted = try container.decode(Bool.self, forKey: .deleted)
        slug = try container.decode(String.self, forKey: .slug)
        title = try container.decode([MultiLanguage<String>].self, forKey: .title)
        shortDescription = try container.decode([MultiLanguage<String>].self, forKey: .shortDescription)
        content = try container.decode([MultiLanguage<String>].self, forKey: .content)
        
        // Decode optional fields
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        updatedBy = try container.decodeIfPresent(String.self, forKey: .updatedBy)
        deletedBy = try container.decodeIfPresent(String.self, forKey: .deletedBy)
        deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
        preparationTime = try container.decodeIfPresent(Int.self, forKey: .preparationTime)
        cookingTime = try container.decodeIfPresent(Int.self, forKey: .cookingTime)
        difficultLevel = try container.decodeIfPresent(String.self, forKey: .difficultLevel)
        thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        
        // Handle arrays that might be null with defaults
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        mealCategories = try container.decodeIfPresent([String].self, forKey: .mealCategories) ?? []
        ingredientCategories = try container.decodeIfPresent([String].self, forKey: .ingredientCategories) ?? []
        videos = try container.decodeIfPresent([String].self, forKey: .videos) ?? []
        ingredients = try container.decodeIfPresent([IngredientsInDish].self, forKey: .ingredients) ?? []
        relatedDishes = try container.decodeIfPresent([String].self, forKey: .relatedDishes) ?? []
        
        // The problematic field - handle completely null value
        labels = try container.decodeIfPresent([String].self, forKey: .labels)
    }
    
    // Regular init for creating instances in code
    init(id: String, deleted: Bool, createdAt: String?, updatedAt: String?, createdBy: String?,
         updatedBy: String?, deletedBy: String?, deletedAt: String?, slug: String,
         title: [MultiLanguage<String>], shortDescription: [MultiLanguage<String>],
         content: [MultiLanguage<String>], tags: [String], preparationTime: Int?,
         cookingTime: Int?, difficultLevel: String?, mealCategories: [String],
         ingredientCategories: [String], thumbnail: String?, videos: [String],
         ingredients: [IngredientsInDish], relatedDishes: [String], labels: [String]?) {
        
        self.id = id
        self.deleted = deleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.createdBy = createdBy
        self.updatedBy = updatedBy
        self.deletedBy = deletedBy
        self.deletedAt = deletedAt
        self.slug = slug
        self.title = title
        self.shortDescription = shortDescription
        self.content = content
        self.tags = tags
        self.preparationTime = preparationTime
        self.cookingTime = cookingTime
        self.difficultLevel = difficultLevel
        self.mealCategories = mealCategories
        self.ingredientCategories = ingredientCategories
        self.thumbnail = thumbnail
        self.videos = videos
        self.ingredients = ingredients
        self.relatedDishes = relatedDishes
        self.labels = labels
    }
}

struct CreateDishDto: Codable {
    let slug: String
    let title: [MultiLanguage<String>]
    let shortDescription: [MultiLanguage<String>]
    let content: [MultiLanguage<String>]
    let tags: [String]
    let preparationTime: Int?
    let cookingTime: Int?
    let difficultLevel: String?
    let mealCategories: [String]
    let ingredientCategories: [String]
    let thumbnail: String?
    let videos: [String]
    let ingredients: [IngredientsInDish]
    let relatedDishes: [String]
    let labels: [String]
}

struct UpdateDishDto: Codable {
    let id: String
    let slug: String
    let title: [MultiLanguage<String>]
    let shortDescription: [MultiLanguage<String>]
    let content: [MultiLanguage<String>]
    let tags: [String]
    let preparationTime: Int?
    let cookingTime: Int?
    let difficultLevel: String?
    let mealCategories: [String]
    let ingredientCategories: [String]
    let thumbnail: String?
    let videos: [String]
    let ingredients: [IngredientsInDish]
    let relatedDishes: [String]
    let labels: [String]
}

struct QueryDishDto: Codable {
    // PagingDto properties
    let page: Int?
    let limit: Int?
    
    // QueryDishDto properties
    let keyword: String?
    let tags: [String]?
    let preparationTimeFrom: Int?
    let preparationTimeTo: Int?
    let cookingTimeFrom: Int?
    let cookingTimeTo: Int?
    let difficultLevels: [String]?
    let mealCategories: [String]?
    let ingredientCategories: [String]?
    let ingredients: [String]?
    let labels: [String]?
}
