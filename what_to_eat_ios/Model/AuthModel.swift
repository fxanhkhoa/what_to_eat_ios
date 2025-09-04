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

// MARK: - JWT Models
struct JWTClaims: Codable {
    // Standard JWT claims
    let sub: String?        // Subject (user ID)
    let exp: Int?           // Expiration time
    let iat: Int?           // Issued at time
    let nbf: Int?           // Not before time
    let iss: String?        // Issuer
    let aud: String?        // Audience
    
    // Custom claims specific to your app
    let id: String?         // User ID
    let email: String?      // User email
    let googleId: String?   // Google ID
    let appleId: String?    // Apple ID
    let githubId: String?   // GitHub ID
    let roleName: String?   // User role name
    let name: String?       // User name
    
    enum CodingKeys: String, CodingKey {
        case sub, exp, iat, nbf, iss, aud
        case id
        case email
        case googleId = "google_id"
        case appleId = "apple_id"
        case githubId = "github_id"
        case roleName = "role_name"
        case name
    }
}

struct JWTToken {
    let header: [String: Any]
    let claims: JWTClaims
    let signature: String
    let isValid: Bool
    let isExpired: Bool
    let expirationDate: Date?
}
