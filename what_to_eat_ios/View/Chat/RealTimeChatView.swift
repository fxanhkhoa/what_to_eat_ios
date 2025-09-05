//
//  RealTimeChatView.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 24/8/25.
//

import SwiftUI
import Combine

/// Reusable real-time chat component
struct RealTimeChatView: View {
    let roomId: String
    let roomType: ChatRoomType
    @ObservedObject var chatService: ChatSocketService
    
    @State private var messageText = ""
    @State private var isTyping = false
    @FocusState private var isMessageFieldFocused: Bool
    @State private var anchorMessageId: String? = nil
    @State private var isAtBottom: Bool = true // Track if user is at bottom
    
    // Get current user id from AuthService
    @ObservedObject private var authService = AuthService.shared
    
    // Custom initializer
    init(roomId: String, roomType: ChatRoomType, chatService: ChatSocketService) {
        self.roomId = roomId
        self.roomType = roomType
        self.chatService = chatService
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat Messages
            chatMessagesView
            
            // Typing Indicators
            if !chatService.typingUsers.isEmpty {
                typingIndicatorView
            }
            
            // Message Input
            messageInputView
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            setupChatConnection()
        }
        .onChange(of: messageText) { _, newValue in
            handleTypingIndicator(newValue)
        }
    }
    
    // MARK: - Chat Messages View
    
    private var chatMessagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .named("chatScrollView")).maxY) {
                            // If the user is at the bottom (within 20pt), set isAtBottom = true
                            let scrollViewHeight = geo.size.height
                            let contentHeight = geo.frame(in: .named("chatScrollView")).height
                            let offset = contentHeight - scrollViewHeight - geo.frame(in: .named("chatScrollView")).minY
                            isAtBottom = offset < 20
                        }
                        .frame(height: 0)
                }
                LazyVStack(spacing: 8) {
                    // Load more button at the top
                    if chatService.hasMoreMessages {
                        loadMoreButton
                            .id("loadMoreButton")
                    }
                    
                    ForEach(chatService.messages) { message in
                        let isMyMessage = message.senderId == authService.profile?.id
                        ChatMessageRow(message: message, isMyMessage: isMyMessage)
                            .id(message.id)
                    }
                }
                .padding()
            }
            .coordinateSpace(name: "chatScrollView")
            .frame(height: 300)
            .refreshable {
                // Set anchor to the first message before loading more
                anchorMessageId = chatService.messages.first?.id
                await loadMoreMessages()
            }
            .onChange(of: chatService.messages.count) { _ in
                // If loading more, scroll to anchor message (first visible before load)
                if let anchorId = anchorMessageId, !chatService.isLoadingMore {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(anchorId, anchor: .top)
                    }
                    anchorMessageId = nil
                } else if let lastMessage = chatService.messages.last, !chatService.isLoadingMore {
                    // Only scroll to bottom for new messages if user is at bottom or last message is mine
                    let isMyMessage = lastMessage.senderId == authService.profile?.id
                    if isAtBottom || isMyMessage {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .onAppear {
                if let lastId = chatService.messages.last?.id {
                    DispatchQueue.main.async {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Typing Indicator
    
    private var typingIndicatorView: some View {
        HStack {
            Text(typingIndicatorText)
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(Color(.systemGray5))
    }
    
    private var typingIndicatorText: String {
        let typingUserIds = chatService.typingUsers
        guard !typingUserIds.isEmpty else { return "" }
        
        // Get the names of users who are typing
        let typingUserNames = typingUserIds.compactMap { userId in
            // First try to find the user in onlineUsers
            if let onlineUser = chatService.onlineUsers.first(where: { $0.id == userId }) {
                return onlineUser.name
            }
            // If not found in online users, return the userId as fallback
            return userId
        }
        
        let count = typingUserNames.count
        if count == 1 {
            return "\(typingUserNames[0]) is typing..."
        } else if count == 2 {
            return "\(typingUserNames[0]) and \(typingUserNames[1]) are typing..."
        } else if count > 2 {
            let firstNames = typingUserNames.prefix(2).joined(separator: ", ")
            return "\(firstNames) and \(count - 2) others are typing..."
        }
        
        return ""
    }
    
    // MARK: - Message Input
    
    private var messageInputView: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $messageText, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .focused($isMessageFieldFocused)
                .lineLimit(1...4)
            
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : Color("PrimaryColor"))
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }
    
    // MARK: - Load More Button
    
    private var loadMoreButton: some View {
        Button(action: {
            // Set anchor to the first message before loading more
            anchorMessageId = chatService.messages.first?.id
            chatService.loadMoreMessages()
        }) {
            HStack(spacing: 8) {
                if chatService.isLoadingMore {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                } else {
                    Image(systemName: "arrow.up.circle")
                        .foregroundColor(.secondary)
                }
                
                Text(chatService.isLoadingMore ? "Loading..." : "Load more messages")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray5))
            .cornerRadius(16)
        }
        .disabled(chatService.isLoadingMore)
        .opacity(chatService.hasMoreMessages ? 1.0 : 0.5)
    }
    
    // MARK: - Helper Methods
    
    private func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        chatService.sendMessage(trimmedMessage)
        DispatchQueue.main.async {
            self.messageText = ""
            self.isMessageFieldFocused = false
        }
        chatService.stopTyping()
    }
    
    private func handleTypingIndicator(_ newValue: String) {
        if !newValue.isEmpty && !isTyping {
            isTyping = true
            chatService.startTyping()
        } else if newValue.isEmpty && isTyping {
            isTyping = false
            chatService.stopTyping()
        }
    }
    
    private func setupChatConnection() {
        // Ensure socket is connected before joining the chat room
        chatService.connectSocket()
        chatService.joinChatRoom(roomId, roomType: roomType)
        chatService.loadMessageHistory(limit: 25)
    }
    
    // MARK: - Load More Messages
    
    private func loadMoreMessages() async {
        guard chatService.hasMoreMessages && !chatService.isLoadingMore else { return }
        chatService.loadMoreMessages()
        
        // Wait for the loading to complete
        while chatService.isLoadingMore {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
    }
}

// MARK: - Chat Message Row

struct ChatMessageRow: View {
    let message: ChatMessage
    let isMyMessage: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    private var isSystemMessage: Bool {
        message.type == .system
    }
    
    private var messageAlignment: HorizontalAlignment {
        if isSystemMessage {
            return .center
        }
        return isMyMessage ? .trailing : .leading
    }
    
    private var bubbleColor: Color {
        if isSystemMessage {
            return Color(.systemGray5)
        } else if isMyMessage {
            return Color("PrimaryColor")
        } else {
            return Color(.systemGray4)
        }
    }
    
    private var textColor: Color {
        if isSystemMessage {
            return .secondary
        } else if isMyMessage {
            return .white
        } else {
            return .primary
        }
    }
    
    var body: some View {
        VStack(alignment: messageAlignment, spacing: 4) {
            if !isSystemMessage {
                HStack {
                    if isMyMessage {
                        Spacer()
                    }
                    Text(message.senderName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    if !isMyMessage {
                        Spacer()
                    }
                }
            }
            
            HStack {
                if isMyMessage {
                    Spacer(minLength: 50)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .font(.subheadline)
                        .foregroundColor(textColor)
                    
                    // Message reactions
                    if !message.reactions.isEmpty {
                        reactionView
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(bubbleColor)
                .cornerRadius(16)
                
                if !isMyMessage {
                    Spacer(minLength: 50)
                }
            }
            
            // Timestamp
            HStack {
                if isMyMessage {
                    Spacer()
                }
                
                Text(DateFormatter.chatTime.string(from: message.date))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                if !isMyMessage {
                    Spacer()
                }
            }
        }
    }
    
    private var reactionView: some View {
        HStack(spacing: 4) {
            ForEach(Array(message.reactions.keys.sorted()), id: \.self) { reaction in
                if let count = message.reactions[reaction], count > 0 {
                    HStack(spacing: 2) {
                        Text(reaction)
                            .font(.caption2)
                        Text("\(count)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let chatTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    RealTimeChatView(
        roomId: "sample-room",
        roomType: .voteGame,
        chatService: ChatSocketService(),
    )
    .frame(height: 300)
    .padding()
}
