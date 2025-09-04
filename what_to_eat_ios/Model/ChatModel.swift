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

struct ChatUser: Codable, Identifiable {
    let id: String
    let name: String
    let avatar: String?
    let isOnline: Bool
    let lastSeen: TimeInterval?
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
