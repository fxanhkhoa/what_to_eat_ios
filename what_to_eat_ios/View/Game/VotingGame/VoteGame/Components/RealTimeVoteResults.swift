//
//  RealTimeVoteResults.swift
//  what_to_eat_ios
//
//  Created by System on 30/8/25.
//

import SwiftUI

struct RealTimeVoteResults: View {
    let voteGame: DishVote
    let selectedDish: String?
    let dishes: [Dish]
    
    let localization = LocalizationService.shared
    
    private func dishForSlug(_ slug: String) -> Dish? {
        dishes.first(where: { $0.slug == slug })
    }
    
    private func totalVotes(_ voteGame: DishVote) -> Int {
        voteGame.dishVoteItems.reduce(0) { total, item in
            total + item.voteUser.count + item.voteAnonymous.count
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.localizedString(for: "live_results"))
                .font(.headline)
            
            ForEach(voteGame.dishVoteItems, id: \.slug) { item in
                VoteResultRow(
                    item: item,
                    dish: dishForSlug(item.slug) ?? SampleData.sampleDish,
                    totalVotes: totalVotes(voteGame),
                    isSelected: selectedDish == item.slug
                )
                .animation(.easeInOut(duration: 0.3), value: item.voteUser.count + item.voteAnonymous.count)
            }
        }
        //        .onReceive(voteGameSocketService.$newVoteGame) { update in
        //            // Handle real-time vote updates
        //            print("Received vote update: \(String(describing: update))")
        //            onVoteUpdate(update)
        //        }
    }
}

#Preview {
    RealTimeVoteResults(
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
        ),
        selectedDish: "pho-bo",
        dishes: SampleData.sampleDishes
    )
    .padding()
}
