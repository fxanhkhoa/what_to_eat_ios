//
//  DishVoteModel.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 19/8/25.
//

import Foundation

// MARK: - DishVoteItem
struct DishVoteItem: Codable, Identifiable, Equatable {
    let id = UUID()
    let slug: String
    let customTitle: String?
    let voteUser: [String]
    let voteAnonymous: [String]
    let isCustom: Bool
    
    enum CodingKeys: String, CodingKey {
        case slug, customTitle, voteUser, voteAnonymous, isCustom
    }
}

// MARK: - DishVote
struct DishVote: Codable, Identifiable, Equatable {
    let id: String
    let deleted: Bool
    let createdAt: String
    let updatedAt: String
    let createdBy: String?
    let updatedBy: String?
    let deletedBy: String?
    let deletedAt: String?
    let title: String
    let description: String
    let dishVoteItems: [DishVoteItem]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case deleted, createdAt, updatedAt, createdBy, updatedBy, deletedBy, deletedAt
        case title, description, dishVoteItems
    }
}

// MARK: - DishVoteFilter
struct DishVoteFilter: Codable {
    let keyword: String?
    let page: Int?
    let limit: Int?
    let sortBy: String?
    let sortOrder: String?
    
    init(keyword: String? = nil, page: Int? = nil, limit: Int? = nil, sortBy: String? = nil, sortOrder: String? = nil) {
        self.keyword = keyword
        self.page = page
        self.limit = limit
        self.sortBy = sortBy
        self.sortOrder = sortOrder
    }
}

// MARK: - CreateDishVoteDto
struct CreateDishVoteDto: Codable {
    let title: String?
    let description: String?
    let dishVoteItems: [DishVoteItem]
    
    init(title: String? = nil, description: String? = nil, dishVoteItems: [DishVoteItem]) {
        self.title = title
        self.description = description
        self.dishVoteItems = dishVoteItems
    }
}

// MARK: - UpdateDishVoteDto
struct UpdateDishVoteDto: Codable {
    let id: String
    let title: String?
    let description: String?
    let dishVoteItems: [DishVoteItem]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, description, dishVoteItems
    }
    
    init(id: String, title: String? = nil, description: String? = nil, dishVoteItems: [DishVoteItem]) {
        self.id = id
        self.title = title
        self.description = description
        self.dishVoteItems = dishVoteItems
    }
}
