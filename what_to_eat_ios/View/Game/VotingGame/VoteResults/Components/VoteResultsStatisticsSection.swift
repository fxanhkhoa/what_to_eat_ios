//
//  VoteResultsStatisticsSection.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 22/8/25.
//

import SwiftUI

struct VoteResultsStatisticsSection: View {
    let dishVote: DishVote
    let totalVotesCount: Int
    let localization: LocalizationService
    
    @Environment(\.colorScheme) private var colorScheme
    
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
                    color: Color("AccentColor")
                )
                
                StatisticCard(
                    title: localization.localizedString(for: "created"),
                    value: DateUtil.formatDate(dishVote.createdAt),
                    icon: "calendar",
                    color: .gray
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
    VoteResultsStatisticsSection(
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
            dishVoteItems: []
        ),
        totalVotesCount: 25,
        localization: LocalizationService.shared
    )
}
