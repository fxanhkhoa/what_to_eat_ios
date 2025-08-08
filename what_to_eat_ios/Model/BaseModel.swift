//
//  Base.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 3/8/25.
//

struct BaseModel: Codable, Identifiable {
    let id: String
    let deleted: Bool
    let createdAt: String
    let updatedAt: String
    let createdBy: String?
    let updatedBy: String?
    let deletedBy: String?
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case deleted, createdAt, updatedAt, createdBy, updatedBy, deletedBy, deletedAt
    }
}

// Generic model for multi-language content
struct MultiLanguage<T: Codable>: Codable {
    let lang: String
    let data: T
    
    // Get localized data from array of MultiLanguage objects
    static func getLocalizedData(from items: [MultiLanguage<T>], for language: String, fallbackLanguage: String = "en") -> T? {
        // First try to find exact match for requested language
        if let match = items.first(where: { $0.lang == language }) {
            return match.data
        }
        
        // If no match, try fallback language
        if let fallback = items.first(where: { $0.lang == fallbackLanguage }) {
            return fallback.data
        }
        
        // If still no match, return the first item or nil
        return items.first?.data
    }
}

// Generic model for paginated API responses
struct APIPagination<T: Codable>: Codable {
    let data: [T]
    let count: Int
}

// DTO for pagination parameters
struct PagingDto: Codable {
    let page: Int?
    let limit: Int?
}
