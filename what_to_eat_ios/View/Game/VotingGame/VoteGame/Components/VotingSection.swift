//
//  VotingSection.swift
//  what_to_eat_ios
//
//  Created by System on 30/8/25.
//

import SwiftUI

struct VotingSection: View {
    let voteGame: DishVote
    let selectedDish: String?
    let dishes: [Dish]
    let onDishSelect: (String) -> Void
    let onSubmitVote: () -> Void
    
    private func dishForSlug(_ slug: String) -> Dish? {
        dishes.first(where: { $0.slug == slug })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cast Your Vote")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(voteGame.dishVoteItems, id: \.slug) { item in
                    VotingDishCard(
                        item: item,
                        dish: dishForSlug(item.slug),
                        isSelected: selectedDish == item.slug,
                        onTap: {
                            onDishSelect(item.slug)
                        }
                    )
                }
            }
            
            if selectedDish != nil {
                Button(action: onSubmitVote) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                        Text("Submit Vote")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("PrimaryColor"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: selectedDish)
    }
}

#Preview {
    VotingSection(
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
        dishes: SampleData.sampleDishes,
        onDishSelect: { _ in },
        onSubmitVote: {}
    )
    .padding()
}
