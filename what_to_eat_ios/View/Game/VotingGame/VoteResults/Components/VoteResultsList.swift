//
//  VoteResultsList.swift
//  what_to_eat_ios
//
//  Created by GitHub Copilot on 4/9/25.
//

import SwiftUI

struct VoteResultsList: View {
    let enrichedVoteResults: [EnrichedVoteResult]
    let maxVotes: Int
    private let localization = LocalizationService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(localization.localizedString(for: "all_results"))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 12) {
                ForEach(Array(enrichedVoteResults.enumerated()), id: \.element.id) { index, result in
                    EnrichedVoteResultCard(
                        result: result,
                        maxVotes: maxVotes,
                        isWinner: result.totalVotes == maxVotes && maxVotes > 0,
                        position: index + 1,
                        localization: localization
                    )
                }
            }
        }
    }
}

#Preview {
    VoteResultsList(
        enrichedVoteResults: [
            EnrichedVoteResult(
                dishVoteItem: DishVoteItem(slug: "pho-bo", customTitle: nil, voteUser: ["user1", "user2"], voteAnonymous: ["anon1"], isCustom: false),
                dish: nil,
                totalVotes: 3,
                userVotes: 2,
                anonymousVotes: 1
            ),
            EnrichedVoteResult(
                dishVoteItem: DishVoteItem(slug: "banh-mi", customTitle: nil, voteUser: ["user1"], voteAnonymous: [], isCustom: false),
                dish: nil,
                totalVotes: 1,
                userVotes: 1,
                anonymousVotes: 0
            )
        ],
        maxVotes: 3
    )
}
