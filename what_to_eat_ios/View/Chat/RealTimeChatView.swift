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
                LazyVStack(spacing: 8) {
                    ForEach(chatService.messages) { message in
                        let isMyMessage = message.senderId == authService.profile?.id
                        ChatMessageRow(message: message, isMyMessage: isMyMessage)
                            .id(message.id)
                    }
                }
                .padding()
            }
            .frame(height: 300)
            // Scroll to bottom on new message or initial load
            .onChange(of: chatService.messages.count) { _, _ in
                if let lastId = chatService.messages.last?.id {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastId, anchor: .bottom)
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
        let typingCount = chatService.typingUsers.count
        if typingCount == 1 {
            return "Someone is typing..."
        } else if typingCount > 1 {
            return "\(typingCount) people are typing..."
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
        chatService.loadMessageHistory()
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
