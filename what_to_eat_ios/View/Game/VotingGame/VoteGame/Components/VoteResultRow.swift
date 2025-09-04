//
//  VoteResultRow.swift
//  what_to_eat_ios
//
//  Created by System on 30/8/25.
//

import SwiftUI

struct VoteResultRow: View {
    let item: DishVoteItem
    let dish: Dish // Placeholder dish data
    let totalVotes: Int
    let isSelected: Bool
    
    let localiztion = LocalizationService.shared
    
    private var voteCount: Int {
        item.voteUser.count + item.voteAnonymous.count
    }
    
    private var percentage: Double {
        totalVotes > 0 ? Double(voteCount) / Double(totalVotes) : 0.0
    }
    
    private var dishTitle: String {
        MultiLanguage.getLocalizedData(from: dish.title, for: localiztion.currentLanguage.rawValue) ?? "Untitled"
    }
    
    var body: some View {
        HStack {
            Text(item.isCustom ? (item.customTitle ?? "Custom") : dishTitle)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
            
            Spacer()
            
            Text("\(voteCount)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .background(
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color("PrimaryColor").opacity(0.2))
                    .frame(width: geometry.size.width * percentage)
                    .animation(.easeInOut(duration: 0.5), value: percentage)
            }
        )
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    VStack(spacing: 8) {
        VoteResultRow(
            item: DishVoteItem(
                slug: "pho-bo",
                customTitle: nil, voteUser: ["user1", "user2"],
                voteAnonymous: ["anon1"],
                isCustom: false
            ),
            dish: SampleData.sampleDish,
            totalVotes: 10,
            isSelected: false
        )
        
        VoteResultRow(
            item: DishVoteItem(
                slug: "custom-dish",
                customTitle: "My Special Dish", voteUser: ["user3"],
                voteAnonymous: [],
                isCustom: true
            ),
            dish: SampleData.sampleDish,
            totalVotes: 10,
            isSelected: true
        )
    }
    .padding()
}
