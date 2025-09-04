//
//  VoteResultsStatistics.swift
//  what_to_eat_ios
//
//  Created by GitHub Copilot on 4/9/25.
//

import SwiftUI

struct VoteResultsStatistics: View {
    let dishVote: DishVote
    let totalVotesCount: Int
    @Environment(\.colorScheme) private var colorScheme
    private let localization = LocalizationService.shared
    
    var body: some View {
        VStack(spacing: 16) {
            Text(localization.localizedString(for: "vote_statistics"))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                StatisticCard(
                    title: localization.localizedString(for: "total_votes"),
                    value: "\(totalVotesCount)",
                    icon: "hand.raised.fill",
                    color: Color("PrimaryColor")
                )
                
                StatisticCard(
                    title: localization.localizedString(for: "total_dishes"),
                    value: "\(dishVote.dishVoteItems.count)",
                    icon: "fork.knife",
                    color: .orange
                )
                
                StatisticCard(
                    title: localization.localizedString(for: "created"),
                    value: DateUtil.formatDate(dishVote.createdAt),
                    icon: "calendar",
                    color: .blue
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(radius: 2)
        )
    }
}

#Preview {
    VoteResultsStatistics(
        dishVote: DishVote(
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
            dishVoteItems: [
                DishVoteItem(slug: "pho-bo", customTitle: nil, voteUser: ["user1", "user2"], voteAnonymous: ["anon1"], isCustom: false),
                DishVoteItem(slug: "banh-mi", customTitle: nil, voteUser: ["user1"], voteAnonymous: [], isCustom: false)
            ]
        ),
        totalVotesCount: 3
    )
}