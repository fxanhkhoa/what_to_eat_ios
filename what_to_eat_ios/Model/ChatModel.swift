//
//  ChatModel.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 30/8/25.
//

import Foundation

// MARK: - Supporting Models

struct ChatMessage: Codable, Identifiable {
    let id: String
    let content: String
    let senderId: String
    let senderName: String
    let senderAvatar: String?
    let type: ChatMessageType
    let timestamp: TimeInterval
    var reactions: [String: Int] = [:]
    let roomId: String
    let createdAt: String
    let updatedAt: String
    let deleted: Bool
    
    var date: Date {
        Date(timeIntervalSince1970: timestamp)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case senderId
        case senderName
        case senderAvatar
        case type
        case timestamp
        case reactions
        case roomId
        case createdAt
        case updatedAt
        case deleted
    }
}

struct ChatHistoryMessage: Codable, Identifiable {
    let id: String
    let content: String
    let senderId: String
    let senderName: String
    let senderAvatar: String?
    let type: ChatMessageType
    let timestamp: TimeInterval
    var reactions: [String: Int] = [:]
    let roomId: String
    
    var date: Date {
        Date(timeIntervalSince1970: timestamp)
    }
}

struct ChatUser: Codable {
    let userId: String
    let userName: String
    let avatar: String?
    let isOnline: Bool
    let lastSeen: TimeInterval?
}

struct ChatUserInApp: Codable {
    let id: String
    let name: String
    let isOnline: Bool
}

enum ChatMessageType: String, Codable, CaseIterable {
    case text = "text"
    case image = "image"
    case file = "file"
    case system = "system"
    case vote = "vote"
    case poll = "poll"
}

enum ChatRoomType: String, Codable, CaseIterable {
    case voteGame = ""
    case general = "general"
    case direct = "direct"
    case group = "group"
}

// MARK: - Chat Room Models

struct ChatRoom: Codable, Identifiable {
    let id: String?
    let name: String
    let type: String // Can be ChatRoomType enum or custom string
    let roomId: String // External reference ID (e.g., vote game ID)
    let participants: [String] // User IDs
    let onlineUsers: [String]
    let typingUsers: [String]
    let createdAt: String // ISO string format
    let updatedAt: String
    let deleted: Bool
    
    // Computed property to get ChatRoomType if it matches
    var roomType: ChatRoomType? {
        ChatRoomType(rawValue: type)
    }
    
    // Date computed properties for convenience
    var createdDate: Date? {
        ISO8601DateFormatter().date(from: createdAt)
    }
    
    var updatedDate: Date? {
        ISO8601DateFormatter().date(from: updatedAt)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
        case type
        case roomId
        case participants
        case onlineUsers
        case typingUsers
        case createdAt
        case updatedAt
        case deleted
    }
}

struct ChatRoomUpdated: Codable {
    let onlineUsers: [String]
    let room: ChatRoom
}
