//
//  AuthModel.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 18/8/25.
//

import Foundation

struct ResultToken: Codable {
    let token: String
    let refreshToken: String
}

struct JWTTokenPayload: Codable {
    let id: String
    let email: String
    let roleName: String
    let googleId: String
    let name: String
    let exp: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case roleName = "role_name"
        case googleId = "google_id"
        case name
        case exp
    }
}

struct RetrievedTokenFromRefreshToken: Codable {
    let token: String
}

struct RolePermission: Codable {
    let name: String
    let permission: [String]
    let description: String?
    // BaseModel fields
    let id: String
    let deleted: Bool
    let createdAt: String
    let updatedAt: String
    let createdBy: String?
    let updatedBy: String?
    let deletedBy: String?
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case name, permission, description
        case id = "_id"
        case deleted, createdAt, updatedAt, createdBy, updatedBy, deletedBy, deletedAt
    }
}
