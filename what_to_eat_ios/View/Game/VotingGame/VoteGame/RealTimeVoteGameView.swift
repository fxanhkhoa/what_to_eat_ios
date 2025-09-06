//
//  RealTimeVoteGameView.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 24/8/25.
//

import SwiftUI
import Combine

/// Example view demonstrating real-time vote game functionality
struct RealTimeVoteGameView: View {
    let voteGameId: String
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject private var chatSocketService = ChatSocketService()
    @StateObject private var socketManager = SocketIOManager.shared
    
    @State private var voteGameSocketService = VoteGameSocketService()
    @State private var selectedDish: String?
    @State private var showingChat = false
    @State private var voteGame: DishVote?
    @State private var voteDishes: [Dish] = []
    @State private var cancellables = Set<AnyCancellable>()
    
    let localization = LocalizationService.shared
    
    private let dishvoteService = DishVoteService()
    private let dishService = DishService()
    
    private var senderId: String {
        chatSocketService.currentUserId
    }
    
    private var senderName: String {
        chatSocketService.currentUserName
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Connection Status Bar
                ConnectionStatusBar(
                    isConnected: socketManager.isConnected,
                    onReconnect: {
                        socketManager.reconnect()
                    }
                )
                
                // Main Content with ScrollView to prevent cutoff
                if let voteGame = voteGame {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Player Info Header
                            PlayerInfoHeader(playerName: senderName)
                            
                            // Vote Game Header
                            VoteGameHeader(voteGame: voteGame)
                            
                            // Real-time Vote Results
                            RealTimeVoteResults(
                                voteGame: voteGame,
                                selectedDish: selectedDish,
                                dishes: voteDishes
                            )
                            
                            // Voting Section
                            VotingSection(
                                voteGame: voteGame,
                                selectedDish: selectedDish,
                                dishes: voteDishes,
                                onDishSelect: selectDish,
                                onSubmitVote: submitVote
                            )
                            
                            // Chat Section with fixed height to ensure it's fully visible
                            LiveChatSection(
                                voteGameId: voteGameId,
                                showingChat: $showingChat,
                                chatSocketService: chatSocketService,
                                localization: localization
                            )
                        }
                        .padding()
                    }
                } else {
                    Spacer()
                    LoadingView(localization: LocalizationService.shared)
                    Spacer()
                }
            }
            .navigationTitle(localization.localizedString(for: "live_vote_game"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    connectionStatusButton
                }
            }
            .onAppear {
                setupRealTimeConnection()
            }
            .onDisappear {
                disconnectFromRealTime()
            }
            .onReceive(voteGameSocketService.$newVoteGame) { newValue in
//                print("Received new vote game update via socket", newValue as Any)
                if let value = newValue {
                    voteGame = value
                }
            }
        }
    }
    
    // MARK: - Connection Status Button
    
    private var connectionStatusButton: some View {
        Button(action: {
            if socketManager.isConnected {
                socketManager.disconnect()
            } else {
                socketManager.connect()
            }
        }) {
            Image(systemName: socketManager.isConnected ? "wifi" : "wifi.slash")
                .foregroundColor(socketManager.isConnected ? .green : .red)
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupRealTimeConnection() {
        // Connect to socket if not already connected
        if !socketManager.isConnected {
            socketManager.connect()
        }
        
        // Subscribe to vote game updates
        voteGameSocketService.subscribeToVoteGame(voteGameId)
        
        // Load initial vote game data
        loadVoteGameData()
    }
    
    private func disconnectFromRealTime() {
        // Emit user left event with authenticated user name
        socketManager.emit("user_left_vote", data: [
            "voteGameId": voteGameId,
            "senderId": senderId,
            "timestamp": Date().timeIntervalSince1970
        ])
        
        voteGameSocketService.unsubscribeFromVoteGame(voteGameId)
        chatSocketService.leaveChatRoom()
    }
    
    private func loadVoteGameData() {
        // In a real app, you would fetch this from your API
        // For demo purposes, we'll create a sample vote game
        dishvoteService.findById(id: voteGameId)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error loading vote game: \(error)")
                }
                if case .finished = completion {
                    print("Finished loading vote game")
                }
            } receiveValue: { voteGame in
                self.voteGame = voteGame
                self.voteGameSocketService = VoteGameSocketService()
                // Fetch dishes for all slugs in dishVoteItems using parallel findBySlug calls
                let slugs = voteGame.dishVoteItems.map { $0.slug }
                let dishPublishers = slugs.map { slug in
                    self.dishService.findBySlug(slug: slug)
                }
                
                Publishers.MergeMany(dishPublishers)
                    .collect()
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            print("Error loading dishes: \(error)")
                        }
                    }, receiveValue: { dishes in
                        self.voteDishes = dishes
                    })
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }
    
    private func selectDish(_ dishSlug: String) {
        selectedDish = dishSlug
    }
    
    private func submitVote() {
        guard let selectedDish = selectedDish else { return }
        
        var isVoting = true
        
        voteGame?.dishVoteItems.forEach {item in
            if (item.slug != selectedDish) {
                return
            }
            if (item.voteAnonymous.contains(senderId) || (item.voteUser.contains(senderId))) {
                // User has already voted
                isVoting = false
            }
        }
        
        let data: DishVoteSubmit = DishVoteSubmit(
            slug: selectedDish,
            myName: senderId, // Use authenticated user name
            userID: senderId, // Use authenticated user ID
            isVoting: isVoting
        )
        
        let options: VoteOptions = VoteOptions(roomID: voteGameId)
        
        // Submit vote via socket
        voteGameSocketService.submitVote(
            voteData: data, options: options
        )
        
        // Clear selection
        self.selectedDish = nil
    }
    
    private func totalVotes(_ voteGame: DishVote) -> Int {
        voteGame.dishVoteItems.reduce(0) { total, item in
            total + item.voteUser.count + item.voteAnonymous.count
        }
    }
    
    private func updateVoteGameWithNewVote(_ voteUpdate: VoteUpdate) {
        guard let currentVoteGame = voteGame else { return }
        
        // Update the vote counts in real-time
        if currentVoteGame.dishVoteItems.firstIndex(where: { $0.slug == voteUpdate.dishSlug }) != nil {
            // In a real app, you would properly update the vote counts based on the update data
            // For now, we'll just increment the count
            // currentVoteGame.dishVoteItems[index].voteUser.append(...)
        }
        
        voteGame = currentVoteGame
    }
}

#Preview {
    RealTimeVoteGameView(voteGameId: "68a8428636891bcad994b6af")
}
