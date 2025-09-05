//
//  VoteResultsView.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 22/8/25.
//

import SwiftUI
import Combine

struct VoteResultsView: View {
    let dishVote: DishVote
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    private let localization = LocalizationService.shared
    private let dishService = DishService()
    
    // State for dish data
    @State private var enrichedVoteResults: [EnrichedVoteResult] = []
    @State private var isLoadingDishes = true
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showShareSheet = false
    
    // Calculate basic results
    private var voteResults: [VoteResult] {
        let results = dishVote.dishVoteItems.map { item in
            let totalVotes = item.voteUser.count + item.voteAnonymous.count
            return VoteResult(
                dishVoteItem: item,
                totalVotes: totalVotes,
                userVotes: item.voteUser.count,
                anonymousVotes: item.voteAnonymous.count
            )
        }
        return results.sorted { $0.totalVotes > $1.totalVotes }
    }
    
    private var winner: EnrichedVoteResult? {
        enrichedVoteResults.first
    }
    
    private var totalVotesCount: Int {
        enrichedVoteResults.reduce(0) { $0 + $1.totalVotes }
    }
    
    private var maxVotes: Int {
        enrichedVoteResults.map { $0.totalVotes }.max() ?? 0
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    VoteResultsHeader(
                        dishVote: dishVote,
                    )
                    
                    if isLoadingDishes {
                        // Loading state
                        LoadingView(localization: localization)
                            .frame(height: 200)
                    } else {
                        // Winner Section
//                        if let winner = winner, winner.totalVotes > 0 {
//                            VoteResultsWinner(
//                                winner: winner,
//                                maxVotes: maxVotes,
//                            )
//                        }
                        
                        // All Results Section
                        VoteResultsList(
                            enrichedVoteResults: enrichedVoteResults,
                            maxVotes: maxVotes,
                        )
                        
                        // Vote Statistics
                        VoteResultsStatisticsSection(
                            dishVote: dishVote,
                            totalVotesCount: totalVotesCount,
                            localization: localization
                        )
                    }
                }
                .padding()
            }
            .navigationTitle(localization.localizedString(for: "view_results"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text(localization.localizedString(for: "back"))
                        }
                        .foregroundColor(Color("PrimaryColor"))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color("PrimaryColor"))
                    }
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6).opacity(0.3),
                        colorScheme == .dark ? Color(.systemGray5) : Color.white
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .onAppear {
            loadDishesData()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [generateShareText()])
        }
    }
    
    // MARK: - Data Loading
    
    private func loadDishesData() {
        isLoadingDishes = true
        
        // Get unique non-custom dish slugs
        let dishSlugs = dishVote.dishVoteItems
            .filter { !$0.isCustom }
            .map { $0.slug }
        
        // Create publishers for parallel dish queries
        let dishPublishers = dishSlugs.map { slug in
            dishService.findBySlug(slug: slug)
                .map { Optional($0) }
                .catch { error -> AnyPublisher<Dish?, Never> in
                    print("Failed to load dish with slug \(slug): \(error)")
                    return Just(nil).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        
        // Execute parallel queries
        if dishPublishers.isEmpty {
            // No dishes to query, create enriched results with custom dishes only
            createEnrichedResults(with: [])
        } else {
            Publishers.MergeMany(dishPublishers)
                .collect()
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error loading dishes: \(error)")
                        createEnrichedResults(with: [])
                    }
                }, receiveValue: { dishes in
                    let validDishes = dishes.compactMap { $0 }
                    createEnrichedResults(with: validDishes)
                })
                .store(in: &cancellables)
        }
    }
    
    private func createEnrichedResults(with dishes: [Dish]) {
        let dishMap = Dictionary(uniqueKeysWithValues: dishes.map { ($0.slug, $0) })
        
        enrichedVoteResults = voteResults.map { result in
            let dish = result.dishVoteItem.isCustom ? nil : dishMap[result.dishVoteItem.slug]
            return EnrichedVoteResult(
                dishVoteItem: result.dishVoteItem,
                dish: dish,
                totalVotes: result.totalVotes,
                userVotes: result.userVotes,
                anonymousVotes: result.anonymousVotes
            )
        }
        
        isLoadingDishes = false
    }
    
    // MARK: - Share Results
    
    private func generateShareText() -> String {
        var text = "\(localization.localizedString(for: "share_voting_results")): \(dishVote.title)\n\n"
        
        if let winner = winner, winner.totalVotes > 0 {
            let dishName = winner.displayName
            text += "\(localization.localizedString(for: "share_winner")): \(dishName) \(localization.localizedString(for: "share_with")) \(winner.totalVotes) \(localization.localizedString(for: "votes"))!\n\n"
        }
        
        text += "\(localization.localizedString(for: "share_all_results")):\n"
        for (index, result) in enrichedVoteResults.enumerated() {
            let dishName = result.displayName
            text += "\(index + 1). \(dishName): \(result.totalVotes) \(localization.localizedString(for: "votes"))\n"
        }
        
        text += "\n\(localization.localizedString(for: "total_votes")): \(totalVotesCount)"
        return text
    }
}

#Preview {
    VoteResultsView(dishVote: DishVote(
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
            DishVoteItem(slug: "pho-bo", customTitle: nil, voteUser: ["user1", "user2", "user3"], voteAnonymous: ["anon1", "anon2"], isCustom: false),
            DishVoteItem(slug: "banh-mi", customTitle: nil, voteUser: ["user4"], voteAnonymous: ["anon3"], isCustom: false),
            DishVoteItem(slug: "custom-dish", customTitle: "My Special Dish", voteUser: ["user5", "user6"], voteAnonymous: [], isCustom: true)
        ]
    ))
}
