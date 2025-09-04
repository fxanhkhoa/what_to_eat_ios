//
//  UserModel.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 30/8/25.
//

import Foundation

struct UserModel: Codable, Identifiable {
    var id: String
    var email: String
    var password: String?
    var name: String?
    var dateOfBirth: String?
    var address: String?
    var phone: String?
    var googleID: String?
    var facebookID: String?
    var appleID: String?
    var githubID: String?
    var avatar: String?
    var deleted: Bool?
    var deletedAt: String?
    var deletedBy: String?
    var updatedAt: String?
    var updatedBy: String?
    var createdAt: String?
    var createdBy: String?
    var roleName: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case password
        case name
        case dateOfBirth
        case address
        case phone
        case googleID
        case facebookID
        case appleID
        case githubID
        case avatar
        case deleted
        case deletedAt
        case deletedBy
        case updatedAt
        case updatedBy
        case createdAt
        case createdBy
        case roleName
    }
}

struct QueryUserDto: Codable {
    var keyword: String
    var email: String
    var phoneNumber: String
    var roleName: [String]
}

struct CreateUserDto: Codable {
    var email: String
    var password: String?
    var name: String?
    var dateOfBirth: Date?
    var address: String?
    var phone: String?
    var googleID: String?
    var facebookID: String?
    var appleID: String?
    var githubID: String?
    var avatar: String?
}

struct UpdateUserDto: Codable {
    var id: String
    var email: String
    var name: String?
    var dateOfBirth: Date?
    var address: String?
    var phone: String?
    var googleID: String?
    var facebookID: String?
    var appleID: String?
    var githubID: String?
    var avatar: String?
}
