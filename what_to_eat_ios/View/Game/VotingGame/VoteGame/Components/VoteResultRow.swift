//
//  VoteResultRow.swift
//  what_to_eat_ios
//
//  Created by System on 30/8/25.
//

import SwiftUI

struct VoteResultRow: View {
    let item: DishVoteItem
    let dish: Dish
    let totalVotes: Int
    let isSelected: Bool
    
    let localiztion = LocalizationService.shared
    @State private var showVoters = false
    
    private var voteCount: Int {
        item.voteUser.count + item.voteAnonymous.count
    }
    
    private var percentage: Double {
        totalVotes > 0 ? Double(voteCount) / Double(totalVotes) : 0.0
    }
    
    private var dishTitle: String {
        MultiLanguage.getLocalizedData(from: dish.title, for: localiztion.currentLanguage.rawValue) ?? localiztion.localizedString(for: "untitled")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Vote result bar (existing functionality)
            VStack(spacing: 0) {
                HStack {
                    Text(item.isCustom ? (item.customTitle ?? localiztion.localizedString(for: "custom_dish")) : dishTitle)
                        .font(.subheadline)
                        .fontWeight(isSelected ? .semibold : .regular)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("\(voteCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Toggle button to show/hide voters
                        if voteCount > 0 {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showVoters.toggle()
                                }
                            }) {
                                Image(systemName: showVoters ? "chevron.up" : "chevron.down")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
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
            }
            
            // Voter list (new functionality)
            if showVoters && voteCount > 0 {
                VoterListView(
                    userIds: item.voteAnonymous,
                    anonymousCount: item.voteAnonymous.count
                )
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray6).opacity(0.3))
                .cornerRadius(6)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .cornerRadius(8)
    }
}

#Preview {
    VStack(spacing: 8) {
        VoteResultRow(
            item: DishVoteItem(
                slug: "pho-bo",
                customTitle: nil,
                voteUser: ["user1", "user2"],
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
                customTitle: "My Special Dish",
                voteUser: ["user3"],
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
