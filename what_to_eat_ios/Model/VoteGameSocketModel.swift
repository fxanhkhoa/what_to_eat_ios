//
//  VoteGameSocketModel.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 24/8/25.
//

struct DishVoteSubmit: Codable {
    let slug: String;
    let myName: String;
    let userID: String?;
    let isVoting: Bool;
    
    enum CodingKeys: String, CodingKey {
        case slug, myName, userID, isVoting
    }
    
    init(slug: String, myName: String, userID: String? = nil, isVoting: Bool) {
        self.slug = slug
        self.myName = myName
        self.userID = userID
        self.isVoting = isVoting
    }
}

struct VoteOptions: Codable {
    let roomID: String;
    
    enum CodingKeys: String, CodingKey {
        case roomID
    }
}
