//
//  VoteGameListView.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 20/8/25.
//

import SwiftUI
import Combine

struct VoteGameListView: View {
    @StateObject private var viewModel = VoteGameListViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingCreateVote = false
    @State private var showingFilterSheet = false
    @State private var searchText = ""
    let localization = LocalizationService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Header
                searchAndFilterHeader
                
                // Vote Games List
                voteGamesList
            }
            .navigationTitle("voting_game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Color("PrimaryColor"))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateVote = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color("PrimaryColor"))
                    }
                }
            }
            .sheet(isPresented: $showingCreateVote) {
                VotingGameCreateView()
            }
            .sheet(isPresented: $showingFilterSheet) {
                VoteGameFilterView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadVoteGames()
            }
            .refreshable {
                await viewModel.refreshVoteGames()
            }
        }
        .onChange(of: searchText) { _, newValue in
            viewModel.updateSearchKeyword(newValue)
        }
    }
    
    // MARK: - Search and Filter Header
    private var searchAndFilterHeader: some View {
        HStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search vote games...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
            )
            .frame(maxWidth: .infinity)
            
            // Filter Button
            Button(action: {
                showingFilterSheet = true
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    if viewModel.hasActiveFilters {
                        Circle()
                            .fill(Color("PrimaryColor"))
                            .frame(width: 8, height: 8)
                    }
                }
                .foregroundColor(viewModel.hasActiveFilters ? Color("PrimaryColor") : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                )
            }
        }
        .padding()
    }
    
    // MARK: - Vote Games List
    private var voteGamesList: some View {
        Group {
            if viewModel.isLoading && viewModel.voteGames.isEmpty {
                LoadingView(localization: localization)
            } else if viewModel.voteGames.isEmpty {
                EmptyStateView(
                    localization: localization,
                    title: localization.localizedString(for: "No Vote Games Found"),
                    subtitle: viewModel.hasActiveFilters || !searchText.isEmpty ?
                    localization.localizedString(for:"Try adjusting your search or filter criteria") :
                        localization.localizedString(for:"Create your first vote game to get started"),
                    systemImage: "list.bullet.clipboard",
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.voteGames) { voteGame in
                            VoteGameCard(voteGame: voteGame)
                                .onTapGesture {
                                    // Navigate to vote game detail
                                }
                        }
                        
                        // Load More Indicator
                        if viewModel.hasMorePages {
                            ProgressView()
                                .padding()
                                .onAppear {
                                    viewModel.loadMoreVoteGames()
                                }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Vote Game Card
struct VoteGameCard: View {
    let voteGame: DishVote
    @Environment(\.colorScheme) private var colorScheme
    
    private var totalVotes: Int {
        voteGame.dishVoteItems.reduce(0) { total, item in
            total + item.voteUser.count + item.voteAnonymous.count
        }
    }
    
    private var dishCount: Int {
        voteGame.dishVoteItems.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(voteGame.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    // Status Badge
                    Text("Active")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(6)
                }
                
                if !voteGame.description.isEmpty {
                    Text(voteGame.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
            
            // Stats Row
            HStack(spacing: 20) {
                // Dish Count
                Label("\(dishCount) dishes", systemImage: "fork.knife")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Vote Count
                Label("\(totalVotes) votes", systemImage: "hand.raised.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Created Date
                Text(formatDate(voteGame.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Dish Preview
            if !voteGame.dishVoteItems.isEmpty {
                dishPreviewSection
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {
                    // View results action
                }) {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                        Text("View Results")
                    }
                    .font(.subheadline)
                    .foregroundColor(Color("PrimaryColor"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color("PrimaryColor").opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    // Vote action
                }) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                        Text("Vote Now")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color("PrimaryColor"))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(radius: 2)
        )
    }
    
    // MARK: - Dish Preview Section
    private var dishPreviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dishes in this vote:")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(voteGame.dishVoteItems.prefix(5), id: \.slug) { item in
                        DishPreviewChip(item: item)
                    }
                    
                    if voteGame.dishVoteItems.count > 5 {
                        Text("+\(voteGame.dishVoteItems.count - 5) more")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.gray)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

// MARK: - Dish Preview Chip
struct DishPreviewChip: View {
    let item: DishVoteItem
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: item.isCustom ? "person.crop.circle.badge.plus" : "fork.knife")
                .font(.caption2)
                .foregroundColor(item.isCustom ? .orange : Color("PrimaryColor"))
            
            Text(item.isCustom ? (item.customTitle ?? "Custom") : item.slug)
                .font(.caption2)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(item.isCustom ? Color.orange.opacity(0.1) : Color("PrimaryColor").opacity(0.1))
        )
        .foregroundColor(item.isCustom ? .orange : Color("PrimaryColor"))
    }
}

#Preview {
    VoteGameListView()
}
