//
//  VoteGameHeader.swift
//  what_to_eat_ios
//
//  Created by System on 30/8/25.
//

import SwiftUI

struct VoteGameHeader: View {
    let voteGame: DishVote
    
    let localization = LocalizationService.shared
    
    private func totalVotes(_ voteGame: DishVote) -> Int {
        voteGame.dishVoteItems.reduce(0) { total, item in
            total + item.voteUser.count + item.voteAnonymous.count
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(voteGame.title)
                .font(.title2)
                .fontWeight(.bold)
            
            if !voteGame.description.isEmpty {
                Text(voteGame.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Live indicators
            HStack {
                Label(localization.localizedString(for: "live_updates"), systemImage: "antenna.radiowaves.left.and.right")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Spacer()
                
                Text(String(format: localization.localizedString(for: "votes_count"), totalVotes(voteGame)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VoteGameHeader(
        voteGame: DishVote(
            id: "test-id",
            deleted: false,
            createdAt: "2025-08-30T00:00:00Z",
            updatedAt: "2025-08-30T00:00:00Z",
            createdBy: nil,
            updatedBy: nil,
            deletedBy: nil,
            deletedAt: nil,
            title: "What should we eat for lunch?",
            description: "Vote for your favorite dish from the menu",
            dishVoteItems: [
                DishVoteItem(
                    slug: "pho-bo",
                    customTitle: nil,
                    voteUser: ["user1", "user2"],
                    voteAnonymous: ["anon1"],
                    isCustom: false
                ),
                DishVoteItem(
                    slug: "banh-mi",
                    customTitle: nil,
                    voteUser: ["user3"],
                    voteAnonymous: [],
                    isCustom: false
                )
            ]
        )
    )
    .padding()
}
