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
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingCreateVote = false
    @State private var showingFilterSheet = false
    @State private var searchText = ""
    @State private var showingLogin = false
    @State private var hasLoadedAfterLogin = false
    @State private var selectedVoteGame: DishVote? = nil
    
    let localization = LocalizationService.shared
    
    var body: some View {
        NavigationView {
            // Show login if not authenticated
            if !authViewModel.isAuthenticated {
                loginRequiredView
            } else {
                authenticatedContentView
            }
        }
        .sheet(isPresented: $showingLogin) {
            LoginView {
                showingLogin = false
            }
            .environmentObject(authViewModel)
        }
        .onAppear {
            checkAuthenticationAndLoad()
        }
        .onChange(of: authViewModel.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated && !hasLoadedAfterLogin {
                // User just logged in successfully, reload the vote games
                Task { @MainActor in
                    await viewModel.refreshVoteGames()
                    hasLoadedAfterLogin = true
                }
            } else if !isAuthenticated {
                // User logged out, reset the flag
                hasLoadedAfterLogin = false
            }
        }
        .refreshable {
            if (authViewModel.isAuthenticated) {
                await viewModel.refreshVoteGames()
            }
        }
    }
    
    // MARK: - Login Required View
    private var loginRequiredView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color("PrimaryColor"))
            
            // Title and Message
            VStack(spacing: 12) {
                Text(localization.localizedString(for: "login_required"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(localization.localizedString(for: "login_required_message"))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: {
                    showingLogin = true
                }) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text(localization.localizedString(for: "login_to_continue"))
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("PrimaryColor"))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                
                Button(action: {
                    dismiss()
                }) {
                    Text(localization.localizedString(for: "go_back"))
                        .font(.subheadline)
                        .foregroundColor(Color("PrimaryColor"))
                }
            }
            
            Spacer()
        }
        .navigationTitle(localization.localizedString(for: "voting_games"))
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
        }
    }
    
    // MARK: - Authenticated Content View
    private var authenticatedContentView: some View {
        VStack(spacing: 0) {
            // Search and Filter Header
            searchAndFilterHeader
            
            // Vote Games List
            voteGamesList
        }
        .navigationTitle(localization.localizedString(for: "voting_game"))
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
                .environmentObject(authViewModel)
        }
        .sheet(isPresented: $showingFilterSheet) {
            VoteGameFilterView(viewModel: viewModel)
        }
        .sheet(item: $selectedVoteGame) { voteGame in
            RealTimeVoteGameView(voteGameId: voteGame.id)
        }
        .refreshable {
            await viewModel.refreshVoteGames()
        }
        .onChange(of: searchText) { _, newValue in
            viewModel.updateSearchKeyword(newValue)
        }
        .onChange(of: showingCreateVote) { _, newValue in
            if !newValue {
                // Refresh vote games when create vote sheet is dismissed
                Task { @MainActor in
                    viewModel.loadVoteGames()
                }
            }
        }
        .onChange(of: showingFilterSheet) { _, newValue in
            if !newValue {
                // Refresh vote games when filter sheet is dismissed
                Task { @MainActor in
                    viewModel.loadVoteGames()
                }
            }
        }
        .onChange(of: selectedVoteGame) { _, newValue in
            if newValue == nil {
                // Refresh vote games when vote game sheet is dismissed
                Task { @MainActor in
                    viewModel.loadVoteGames()
                }
            }
        }
        .onAppear {
            // Always reload the list when this view appears (e.g. after returning from a sheet)
            viewModel.loadVoteGames()
        }
    }
    
    // MARK: - Helper Methods
    private func checkAuthenticationAndLoad() {
        if authViewModel.isAuthenticated {
            viewModel.loadVoteGames()
        }
    }
    
    // MARK: - Search and Filter Header
    private var searchAndFilterHeader: some View {
        HStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField(localization.localizedString(for: "search_vote_games"), text: $searchText)
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
                    title: localization.localizedString(for: "no_vote_games_found"),
                    subtitle: viewModel.hasActiveFilters || !searchText.isEmpty ?
                    localization.localizedString(for:"try_adjusting_search") :
                        localization.localizedString(for:"create_first_vote_game"),
                    systemImage: "list.bullet.clipboard",
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.voteGames) { voteGame in
                            VoteGameCard(voteGame: voteGame, onVoteNow: { selectedVoteGame = voteGame })
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
    @State private var showingResults = false
    let onVoteNow: () -> Void
    
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
                    Text(localization.localizedString(for: "active"))
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
                Label("\(dishCount) " + localization.localizedString(for: "dishes"), systemImage: "fork.knife")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Vote Count
                Label("\(totalVotes) " + localization.localizedString(for: "votes"), systemImage: "hand.raised.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Created Date
                Text(DateUtil.formatDate(voteGame.createdAt))
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
                    showingResults = true
                }) {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                        Text(localization.localizedString(for: "view_results"))
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
                    onVoteNow()
                }) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                        Text(localization.localizedString(for: "vote_now"))
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
        .sheet(isPresented: $showingResults) {
            VoteResultsView(dishVote: voteGame)
        }
    }
    
    // MARK: - Dish Preview Section
    private var dishPreviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localization.localizedString(for: "dishes_in_this_vote"))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(voteGame.dishVoteItems.prefix(5), id: \.slug) { item in
                        DishPreviewChip(item: item)
                    }
                    
                    if voteGame.dishVoteItems.count > 5 {
                        Text("+\(voteGame.dishVoteItems.count - 5) " + localization.localizedString(for: "more"))
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
}

// MARK: - Dish Preview Chip
struct DishPreviewChip: View {
    let item: DishVoteItem
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: item.isCustom ? "person.crop.circle.badge.plus" : "fork.knife")
                .font(.caption2)
                .foregroundColor(item.isCustom ? .orange : Color("PrimaryColor"))
            
            Text(item.isCustom ? (item.customTitle ?? localization.localizedString(for: "custom")) : item.slug)
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
