//
//  SocketDemoView.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 24/8/25.
//

import SwiftUI
import Combine

/// Demo view showcasing various Socket.IO functionalities
struct SocketDemoView: View {
    @StateObject private var socketManager = SocketIOManager.shared
    @StateObject private var voteGameService = VoteGameSocketService()
    @StateObject private var chatService = ChatSocketService()
    
    @State private var selectedTab = 0
    @State private var showingCreateVoteGame = false
    @State private var testRoomId = "demo_room_123"
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Connection Tab
                connectionDemoTab
                    .tabItem {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                        Text("Connection")
                    }
                    .tag(0)
                
                // Vote Games Tab
                voteGamesDemoTab
                    .tabItem {
                        Image(systemName: "hand.raised.fill")
                        Text("Vote Games")
                    }
                    .tag(1)
                
                // Chat Tab
                chatDemoTab
                    .tabItem {
                        Image(systemName: "message.circle")
                        Text("Chat")
                    }
                    .tag(2)
                
                // Events Tab
                eventsDemoTab
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Events")
                    }
                    .tag(3)
            }
            .navigationTitle("Socket.IO Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Test Event") {
                        sendTestEvent()
                    }
                    .disabled(!socketManager.isConnected)
                }
            }
        }
        .onAppear {
            setupDemoData()
        }
    }
    
    // MARK: - Connection Demo Tab
    
    private var connectionDemoTab: some View {
        VStack(spacing: 20) {
            // Connection Status Card
            connectionStatusCard
            
            // Connection Controls
            connectionControls
            
            // Connection Info
            connectionInfo
            
            Spacer()
        }
        .padding()
    }
    
    private var connectionStatusCard: some View {
        VStack(spacing: 12) {
            HStack {
                Circle()
                    .fill(socketManager.isConnected ? Color.green : Color.red)
                    .frame(width: 16, height: 16)
                
                Text(socketManager.connectionStatus.description)
                    .font(.headline)
                    .foregroundColor(socketManager.isConnected ? .green : .red)
                
                Spacer()
            }
            
            if let error = socketManager.lastError {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.orange)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var connectionControls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: { socketManager.connect() }) {
                    Label("Connect", systemImage: "link")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(socketManager.isConnected)
                
                Button(action: { socketManager.disconnect() }) {
                    Label("Disconnect", systemImage: "link.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(!socketManager.isConnected)
            }
            
            Button(action: { socketManager.reconnect() }) {
                Label("Reconnect", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var connectionInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Connection Details")
                .font(.headline)
            
            Group {
                InfoRow(label: "Status", value: socketManager.connectionStatus.description)
                InfoRow(label: "Connected", value: socketManager.isConnected ? "Yes" : "No")
                InfoRow(label: "Server", value: APIConstants.baseURL)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Vote Games Demo Tab
    
    private var voteGamesDemoTab: some View {
        VStack(spacing: 16) {
            // Active Vote Games
            voteGamesSection
            
            // Vote Updates
            voteUpdatesSection
            
            Spacer()
        }
        .padding()
    }
    
    private var voteGamesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Vote Games")
                    .font(.headline)
                
                Spacer()
                
                Button("Subscribe to General") {
                    voteGameService.subscribeToGeneralVoteGameEvents()
                }
                .font(.caption)
                .buttonStyle(.bordered)
                .disabled(!socketManager.isConnected)
            }
            
            if voteGameService.activeVoteGames.isEmpty {
                Text("No active vote games")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(voteGameService.activeVoteGames, id: \.id) { voteGame in
                    VoteGameDemoCard(voteGame: voteGame, service: voteGameService)
                }
            }
            
            Button("Create Test Vote Game") {
                createTestVoteGame()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!socketManager.isConnected)
        }
    }
    
    private var voteUpdatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Vote Updates")
                .font(.headline)
            
            if voteGameService.voteUpdates.isEmpty {
                Text("No vote updates yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(voteGameService.voteUpdates.suffix(5).reversed(), id: \.timestamp) { update in
                    VoteUpdateRow(update: update)
                }
            }
        }
    }
    
    // MARK: - Chat Demo Tab
    
    private var chatDemoTab: some View {
        VStack(spacing: 16) {
            // Chat Room Controls
            chatRoomControls
            
            // Chat View
            if socketManager.isConnected {
                RealTimeChatView(
                    roomId: testRoomId,
                    roomType: .general,
                    chatService: chatService
                )
                .frame(maxHeight: .infinity)
            } else {
                Text("Connect to socket to use chat")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
    }
    
    private var chatRoomControls: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Chat Room: \(testRoomId)")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                TextField("Room ID", text: $testRoomId)
                    .textFieldStyle(.roundedBorder)
                
                Button("Join") {
                    chatService.joinChatRoom(testRoomId, roomType: .general)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!socketManager.isConnected)
            }
            
            if !chatService.onlineUsers.isEmpty {
                Text("Online: \(chatService.onlineUsers.map(\.name).joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Events Demo Tab
    
    private var eventsDemoTab: some View {
        VStack(spacing: 16) {
            Text("Socket Events")
                .font(.headline)
            
            // Test Events Section
            testEventsSection
            
            // Custom Event Subscription
            customEventSection
            
            Spacer()
        }
        .padding()
    }
    
    private var testEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Test Events")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                EventButton(title: "Ping", icon: "antenna.radiowaves.left.and.right") {
                    socketManager.emit("ping", data: ["timestamp": Date().timeIntervalSince1970])
                }
                
                EventButton(title: "Test Vote", icon: "hand.raised") {
                    let data: DishVoteSubmit = DishVoteSubmit(slug: "test_dish", myName: "", userID: "test", isVoting: true)
                    let options: VoteOptions = VoteOptions(roomID: "room_1")
                    voteGameService.submitVote(voteData: data, options: options)
                }
                
                EventButton(title: "Test Message", icon: "message") {
                    chatService.sendMessage("Hello from iOS app! 👋")
                }
                
                EventButton(title: "Custom Event", icon: "sparkles") {
                    sendCustomEvent()
                }
            }
        }
    }
    
    private var customEventSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom Event Subscription")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text("Subscribe to custom events and see real-time updates")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Subscribe to 'custom_event'") {
                subscribeToCustomEvent()
            }
            .buttonStyle(.bordered)
            .disabled(!socketManager.isConnected)
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupDemoData() {
        // Create sample vote game data for demo
        let sampleVoteGame = SampleData.sampleDishVote
        voteGameService.activeVoteGames = [sampleVoteGame]
    }
    
    private func sendTestEvent() {
        socketManager.emit("test_event", data: [
            "message": "Hello from iOS!",
            "timestamp": Date().timeIntervalSince1970,
            "platform": "iOS"
        ])
    }
    
    private func createTestVoteGame() {
        let testVoteGame = SampleData.sampleDishVote
        voteGameService.createVoteGame(testVoteGame)
    }
    
    private func sendCustomEvent() {
        socketManager.emit("custom_event", data: [
            "eventType": "demo",
            "data": "Custom event from iOS app",
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    private func subscribeToCustomEvent() {
        _ = socketManager.subscribe(to: "custom_event")
            .sink { event in
                print("Received custom event: \(event.data)")
            }
    }
}

// MARK: - Supporting Views

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.caption)
    }
}

struct VoteGameDemoCard: View {
    let voteGame: DishVote
    let service: VoteGameSocketService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(voteGame.title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text("\(voteGame.dishVoteItems.count) dishes")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Button("Subscribe") {
                    service.subscribeToVoteGame(voteGame.id)
                }
                .buttonStyle(.bordered)
                .font(.caption)
                
                Spacer()
                
                Button("Vote Random") {
                    if let randomDish = voteGame.dishVoteItems.randomElement() {
                        let data: DishVoteSubmit = DishVoteSubmit(slug: randomDish.slug, myName: "iOS Tester", userID: UUID().uuidString, isVoting: true)
                        let options: VoteOptions = VoteOptions(roomID: voteGame.id)
                        service.submitVote(voteData: data, options: options)
                    }
                }
                .buttonStyle(.borderedProminent)
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct VoteUpdateRow: View {
    let update: VoteUpdate
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(update.dishSlug)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("Vote Game: \(update.voteGameId)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(update.voteCount)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text(Date(timeIntervalSince1970: update.timestamp), style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EventButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    @StateObject private var socketManager = SocketIOManager.shared
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .disabled(!socketManager.isConnected)
    }
}

#Preview {
    SocketDemoView()
}
