//
//  VoteResultsWinner.swift
//  what_to_eat_ios
//
//  Created by GitHub Copilot on 4/9/25.
//

import SwiftUI

struct VoteResultsWinner: View {
    let winner: EnrichedVoteResult
    let maxVotes: Int
    @Environment(\.colorScheme) private var colorScheme
    private let localization = LocalizationService.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Winner Badge
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                Text(localization.localizedString(for: "winner"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                    )
            )
            
            // Winner Dish Card
            EnrichedVoteResultCard(
                result: winner,
                maxVotes: maxVotes,
                isWinner: true,
                position: 1,
                localization: localization
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 5)
        )
    }
}

#Preview {
    VoteResultsWinner(
        winner: EnrichedVoteResult(
            dishVoteItem: DishVoteItem(slug: "pho-bo", customTitle: nil, voteUser: ["user1", "user2"], voteAnonymous: ["anon1"], isCustom: false),
            dish: nil,
            totalVotes: 3,
            userVotes: 2,
            anonymousVotes: 1
        ),
        maxVotes: 3
    )
}