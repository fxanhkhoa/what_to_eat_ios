//
//  EnrichedVoteResultCard.swift
//  what_to_eat_ios
//
//  Created by GitHub Copilot on 4/9/25.
//

import SwiftUI

struct EnrichedVoteResultCard: View {
    let result: EnrichedVoteResult
    let maxVotes: Int
    let isWinner: Bool
    let position: Int
    let localization: LocalizationService
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var showDetail: Bool = false
    @State private var pendingShare: Bool = false
    
    private var percentage: Double {
        guard maxVotes > 0 else { return 0.0 }
        return Double(result.totalVotes) / Double(maxVotes)
    }
    
    var body: some View {
        Button(action: {
            showDetail = true
        }) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Dish Image
                    if let thumbnailURL = result.thumbnailURL, !thumbnailURL.isEmpty {
                        AsyncImage(url: URL(string: thumbnailURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "fork.knife")
                                        .foregroundColor(.gray)
                                        .font(.title3)
                                )
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(result.dishVoteItem.isCustom ? Color.orange.opacity(0.2) : Color.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: result.dishVoteItem.isCustom ? "chef.hat.fill" : "fork.knife")
                                    .foregroundColor(result.dishVoteItem.isCustom ? .orange : .gray)
                                    .font(.title3)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(result.displayName)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            Spacer()
                            if isWinner {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                            }
                        }
                        // Summary votes: user + anonymous
                        HStack(spacing: 8) {
//                            HStack(spacing: 4) {
//                                Image(systemName: "person.fill")
//                                    .font(.caption)
//                                    .foregroundColor(.blue)
//                                Text("\(result.userVotes)")
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                            }
                            HStack(spacing: 4) {
                                Image(systemName: "person.crop.circle.badge.questionmark")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(result.anonymousVotes)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(result.totalVotes) \(localization.localizedString(for: "votes"))")
                                .font(.caption)
                                .foregroundColor(Color("PrimaryColor"))
                        }
                    }
                }
                // Progress Bar & Percentage
                VStack(spacing: 8) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                                .frame(height: 12)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: isWinner ?
                                            [.yellow, .orange] :
                                            [Color("PrimaryColor"), Color("PrimaryColor").opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * percentage, height: 12)
                                .animation(.easeInOut(duration: 0.8), value: percentage)
                        }
                    }
                    .frame(height: 12)
                    HStack {
                        Text(String(format: "%.1f%%", percentage * 100))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isWinner ? Color.yellow.opacity(0.5) : Color.clear,
                                lineWidth: isWinner ? 2 : 0
                            )
                    )
                    .shadow(
                        color: isWinner ? .yellow.opacity(0.2) : .black.opacity(0.1),
                        radius: isWinner ? 5 : 2,
                        x: 0,
                        y: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail, onDismiss: {
            if pendingShare {
                pendingShare = false
                NotificationCenter.default.post(name: .triggerShareSheet, object: nil)
            }
        }) {
            if let dish = result.dish {
                DishDetailView(dish: dish)
            } else {
                EmptyView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .requestShareFromDetail)) { _ in
            if showDetail {
                pendingShare = true
                showDetail = false
            } else {
                NotificationCenter.default.post(name: .triggerShareSheet, object: nil)
            }
        }
    }
}

extension Notification.Name {
    static let triggerShareSheet = Notification.Name("triggerShareSheet")
    static let requestShareFromDetail = Notification.Name("requestShareFromDetail")
}

#Preview {
    EnrichedVoteResultCard(
        result: EnrichedVoteResult(
            dishVoteItem: DishVoteItem(slug: "pho-bo", customTitle: nil, voteUser: ["user1", "user2"], voteAnonymous: ["anon1"], isCustom: false),
            dish: nil,
            totalVotes: 3,
            userVotes: 2,
            anonymousVotes: 1
        ),
        maxVotes: 5,
        isWinner: true,
        position: 1,
        localization: LocalizationService.shared
    )
}
