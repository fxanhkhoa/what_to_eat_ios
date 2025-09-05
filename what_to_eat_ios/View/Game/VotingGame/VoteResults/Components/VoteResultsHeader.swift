//
//  VoteResultsHeader.swift
//  what_to_eat_ios
//
//  Created by GitHub Copilot on 4/9/25.
//

import SwiftUI

struct VoteResultsHeader: View {
    let dishVote: DishVote
    private let localization = LocalizationService.shared
    
    var body: some View {
        VStack(spacing: 12) {
            Text(dishVote.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            if !dishVote.description.isEmpty {
                Text(dishVote.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    VoteResultsHeader(dishVote: DishVote(
        id: "1",
        deleted: false,
        createdAt: "2025-08-22T10:30:00.000Z",
        updatedAt: "2025-08-22T10:30:00.000Z",
        createdBy: "user1",
        updatedBy: nil,
        deletedBy: nil,
        deletedAt: nil,
        title: "Best Vietnamese Dishes",
        description: "Vote for your favorite Vietnamese dish!",
        dishVoteItems: []
    ))
}
