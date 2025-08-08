//
//  ContactModel.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 8/8/25.
//

import Foundation

// MARK: - Contact Model
struct Contact: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let message: String
    let deleted: Bool
    let deletedAt: String?
    let deletedBy: String?
    let updatedAt: String?
    let updatedBy: String?
    let createdAt: String?
    let createdBy: String?
    
    // CodingKeys for mapping between Swift property names and JSON keys
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case name
        case message
        case deleted
        case deletedAt
        case deletedBy
        case updatedAt
        case updatedBy
        case createdAt
        case createdBy
    }
    
    // Custom initializer to handle optional values
    init(
        id: String,
        email: String,
        name: String,
        message: String,
        deleted: Bool = false,
        deletedAt: String? = nil,
        deletedBy: String? = nil,
        updatedAt: String? = nil,
        updatedBy: String? = nil,
        createdAt: String? = nil,
        createdBy: String? = nil
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.message = message
        self.deleted = deleted
        self.deletedAt = deletedAt
        self.deletedBy = deletedBy
        self.updatedAt = updatedAt
        self.updatedBy = updatedBy
        self.createdAt = createdAt
        self.createdBy = createdBy
    }
}

// MARK: - Create Contact DTO
struct CreateContactDto: Codable {
    let email: String
    let name: String
    let message: String
    
    init(email: String, name: String, message: String) {
        self.email = email
        self.name = name
        self.message = message
    }
}

// MARK: - Update Contact DTO
struct UpdateContactDto: Codable {
    let id: String
    let email: String
    let name: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case name
        case message
    }
    
    init(id: String, email: String, name: String, message: String) {
        self.id = id
        self.email = email
        self.name = name
        self.message = message
    }
}

// MARK: - Query Contact DTO
struct QueryContactDto: Codable {
    let keyword: String?
    let page: Int
    let limit: Int
    let sortField: String?
    let sortOrder: String?
    
    init(keyword: String? = nil, page: Int = 1, limit: Int = 10, sortField: String? = nil, sortOrder: String? = nil) {
        self.keyword = keyword
        self.page = page
        self.limit = limit
        self.sortField = sortField
        self.sortOrder = sortOrder
    }
    
    // Convert to query parameters for API requests
    func toQueryParameters() -> [String: String] {
        var params: [String: String] = [
            "page": "\(page)",
            "limit": "\(limit)"
        ]
        
        if let keyword = keyword {
            params["keyword"] = keyword
        }
        
        if let sortField = sortField {
            params["sortField"] = sortField
        }
        
        if let sortOrder = sortOrder {
            params["sortOrder"] = sortOrder
        }
        
        return params
    }
}

// MARK: - Contact API Response
struct ContactResponse: Codable {
    let data: [Contact]
    let total: Int
    let page: Int
    let limit: Int
    
    enum CodingKeys: String, CodingKey {
        case data
        case total
        case page
        case limit
    }
}
