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
