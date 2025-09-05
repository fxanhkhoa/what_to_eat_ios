//
//  ChatSocketService.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 24/8/25.
//

import Foundation
import Combine
import OSLog

/// Service for handling chat and messaging real-time events via Socket.IO
@MainActor
class ChatSocketService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var messages: [ChatMessage] = []
    @Published var onlineUsers: [ChatUserInApp] = []
    @Published var typingUsers: [String] = []
    @Published var newMessage: ChatMessage?
    @Published var connectionError: String?
    @Published var isLoadingMore = false
    @Published var hasMoreMessages = true
    
    // MARK: - Private Properties
    private let socketManager = SocketIOManager.shared
    private let authService: AuthService = AuthService.shared
    private let logger = Logger(subsystem: "io.vn.eatwhat", category: "ChatSocketService")
    private var cancellables = Set<AnyCancellable>()
    private var currentChatRoom: String?
    private var typingTimer: Timer?
    private var isSubscriptionsSetup = false
    
    // MARK: - Computed Properties for User Info
    var currentUserId: String {
        if let profile = authService.profile {
            return profile.id
        }
        // Fallback to anonymous ID
        return "anonymous_\(UUID().uuidString.prefix(8))"
    }
    
    var currentUserName: String {
        if let profile = authService.profile, let name = profile.name {
            return name
        }
        // Fallback to anonymous name
        return "Anonymous"
    }
    
    private var currentUserAvatar: String? {
        return authService.user?.profileImageURL
    }
    
    init() {
        observeConnectionStatus()
        // Don't setup subscriptions immediately - wait for connection
    }
    
    // MARK: - Public Methods
    
    /// Ensure socket connection is established
    func connectSocket() {
        if !socketManager.isConnected {
            socketManager.connect()
        }
        
        // Setup subscriptions if not already done and we're connected or connecting
        if !isSubscriptionsSetup {
            ensureConnectionAndSubscriptions()
        }
    }
    
    /// Join a chat room (e.g., for a specific vote game or general chat)
    func joinChatRoom(_ roomId: String, roomType: ChatRoomType = .voteGame) {
        let roomName = "\(roomType.rawValue)\(roomId)"
        print("Joining chat room: \(roomName) as \(self.currentUserName)")
        // Ensure socket is connected and subscriptions are setup
        ensureConnectionAndSubscriptions()
        
        if let currentRoom = currentChatRoom {
            leaveChatRoom(currentRoom)
        }
        
        currentChatRoom = roomName
        socketManager.emit("join_chat_room", data: [
            "roomId": roomId,
            "roomType": roomType.rawValue,
            "senderId": currentUserId,
            "senderName": currentUserName,
            "userAvatar": currentUserAvatar ?? "",
            "timestamp": Date().timeIntervalSince1970
        ])
        
        logger.info("Joined chat room: \(roomName) as \(self.currentUserName)")
    }
    
    /// Leave current chat room
    func leaveChatRoom(_ roomName: String? = nil) {
        let room = roomName ?? currentChatRoom
        guard let roomToLeave = room else { return }
        
        socketManager.emit("leave_chat_room", data: [
            "room": roomToLeave,
            "senderId": currentUserId,
        ])
        
        if roomToLeave == currentChatRoom {
            currentChatRoom = nil
            messages.removeAll()
            onlineUsers.removeAll()
            typingUsers.removeAll()
        }
        
        logger.info("Left chat room: \(roomToLeave)")
    }
    
    /// Send a message to current chat room
    func sendMessage(_ content: String, messageType: ChatMessageType = .text) {
        guard let roomName = currentChatRoom else {
            logger.warning("Cannot send message - not in any chat room")
            return
        }
        
        let messageData: [String: Any] = [
            "content": content,
            "type": messageType.rawValue,
            "room": roomName,
            "senderId": currentUserId,
            "senderName": currentUserName,
            "senderAvatar": currentUserAvatar ?? "",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        socketManager.emit("send_message", data: messageData)
        logger.info("Sent message to room: \(roomName) from \(self.currentUserName)")
    }
    
    /// Send typing indicator
    func startTyping() {
        guard let roomName = currentChatRoom else { return }
        
        socketManager.emit("typing_start", data: [
            "room": roomName,
            "senderId": currentUserId,
            "senderName": currentUserName
        ])
        
        // Auto-stop typing after 3 seconds
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.stopTyping()
            }
        }
    }
    
    /// Stop typing indicator
    func stopTyping() {
        guard let roomName = currentChatRoom else { return }
        
        typingTimer?.invalidate()
        socketManager.emit("typing_stop", data: [
            "room": roomName,
            "senderId": currentUserId,
            "senderName": currentUserName
        ])
    }
    
    /// Get message history for current room with optional pagination
    func loadMessageHistory(limit: Int = 50, loadMore: Bool = false) {
        guard let roomName = currentChatRoom else { return }
        
        if loadMore {
            isLoadingMore = true
        }
        
        let beforeTimestamp = loadMore ? messages.first?.timestamp ?? Date().timeIntervalSince1970 : Date().timeIntervalSince1970
        
        let historyData: [String: Any] = [
            "room": roomName,
            "limit": limit,
            "before": beforeTimestamp
        ]
        
        logger.info("Loading message history for room: \(roomName), limit: \(limit), loadMore: \(loadMore)")
        socketManager.emit("get_message_history", data: historyData)
    }
    
    /// Load more older messages
    func loadMoreMessages() {
        guard hasMoreMessages && !isLoadingMore else { return }
        loadMessageHistory(limit: 20, loadMore: true)
    }
    
    /// React to a message
    func reactToMessage(_ messageId: String, reaction: String) {
        guard let roomName = currentChatRoom else { return }
        
        let reactionData: [String: Any] = [
            "messageId": messageId,
            "reaction": reaction,
            "room": roomName,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        socketManager.emit("message_reaction", data: reactionData)
        logger.info("Reacted to message: \(messageId) with \(reaction)")
    }
    
    // MARK: - Private Methods
    
    private func ensureConnectionAndSubscriptions() {
        // Connect socket if not connected
        if !socketManager.isConnected {
            socketManager.connect()
        }
        
        // Setup subscriptions if not already done
        if !isSubscriptionsSetup {
            setupSocketSubscriptions()
            isSubscriptionsSetup = true
        }
    }
    
    private func setupSocketSubscriptions() {
        // Only setup if we have a connection or are connecting
        guard socketManager.isConnected || socketManager.connectionStatus == .connecting else {
            logger.warning("Attempted to setup subscriptions without socket connection")
            return
        }
        
        logger.info("Setting up chat socket subscriptions")
        
        // Subscribe to new messages
        socketManager.subscribe(to: "message_received")
            .sink { [weak self] event in
                self?.handleNewMessage(event)
            }
            .store(in: &cancellables)
        
        // Subscribe to message history
        socketManager.subscribe(to: "message_history")
            .sink { [weak self] event in
                self?.handleMessageHistory(event)
            }
            .store(in: &cancellables)
        
        // Subscribe to user online/offline status
        socketManager.subscribe(to: "user_joined_chat")
            .sink { [weak self] event in
                self?.handleUserJoinedChat(event)
            }
            .store(in: &cancellables)
        
        socketManager.subscribe(to: "user_left_chat")
            .sink { [weak self] event in
                self?.handleUserLeftChat(event)
            }
            .store(in: &cancellables)
        
        // Subscribe to typing indicators
        socketManager.subscribe(to: "user_typing_start")
            .sink { [weak self] event in
                self?.handleUserStartedTyping(event)
            }
            .store(in: &cancellables)
        
        socketManager.subscribe(to: "user_typing_stop")
            .sink { [weak self] event in
                self?.handleUserStoppedTyping(event)
            }
            .store(in: &cancellables)
        
        // Subscribe to message reactions
        socketManager.subscribe(to: "message_reaction_updated")
            .sink { [weak self] event in
                self?.handleMessageReactionUpdated(event)
            }
            .store(in: &cancellables)
        
        // Subscribe to room updates
        socketManager.subscribe(to: "chat_room_updated")
            .sink { [weak self] event in
                self?.handleChatRoomUpdated(event)
            }
            .store(in: &cancellables)
        
        logger.info("Chat socket subscriptions setup complete")
    }
    
    private func observeConnectionStatus() {
        socketManager.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                if isConnected {
                    self?.connectionError = nil
                    // Setup subscriptions when connected
                    if !(self?.isSubscriptionsSetup ?? false) {
                        self?.setupSocketSubscriptions()
                        self?.isSubscriptionsSetup = true
                    }
                    self?.rejoinChatRoomAfterReconnection()
                } else {
                    self?.connectionError = "Chat disconnected"
                    self?.onlineUsers.removeAll()
                    self?.typingUsers.removeAll()
                    // Reset subscriptions flag so they get re-setup on reconnection
                    self?.isSubscriptionsSetup = false
                }
            }
            .store(in: &cancellables)
        
        socketManager.$lastError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.connectionError = error
            }
            .store(in: &cancellables)
    }
    
    private func rejoinChatRoomAfterReconnection() {
        guard let roomName = currentChatRoom else { return }
        
        // Extract room ID and type from room name
        let components = roomName.split(separator: "_", maxSplits: 1)
        guard components.count == 2,
              let roomType = ChatRoomType(rawValue: String(components[0])),
              let roomId = String(components[1]) as String? else {
            return
        }
        
        joinChatRoom(roomId, roomType: roomType)
        loadMessageHistory() // Reload recent messages
        
        logger.info("Rejoined chat room after reconnection: \(roomName)")
    }
    
    // MARK: - Event Handlers
    
    private func handleNewMessage(_ event: SocketEvent) {
        guard let data = event.data.first as? [String: Any] else {
            logger.error("Invalid message data")
            return
        }
        
        do {
            // Convert the server data to match our ChatMessage model
            var convertedData = data
            
            // Convert senderId from number to string if needed
            if let senderIdNumber = data["senderId"] as? NSNumber {
                convertedData["senderId"] = senderIdNumber.stringValue
            }
            
            // Convert deleted from number to boolean if needed
            if let deletedNumber = data["deleted"] as? NSNumber {
                convertedData["deleted"] = deletedNumber.boolValue
            }
            
            // Ensure senderAvatar is a string or nil
            if convertedData["senderAvatar"] == nil {
                convertedData["senderAvatar"] = ""
            }
            
            // Add missing roomId if not present
            if convertedData["roomId"] == nil {
                convertedData["roomId"] = currentChatRoom ?? ""
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: convertedData)
            let message = try JSONDecoder().decode(ChatMessage.self, from: jsonData)
            
            messages.append(message)
            
            newMessage = message
            
            // Sort messages by timestamp
            messages.sort { $0.timestamp < $1.timestamp }
            
            logger.info("Received new message from: \(message.senderName)")
            event.acknowledge()
            
        } catch {
            print(String(describing: error))
            logger.error("Failed to decode message: \(error.localizedDescription)")
            // Print the actual data for debugging
            print("Failed to decode data: \(data)")
            if let jsonData = try? JSONSerialization.data(withJSONObject: data),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON string: \(jsonString)")
            }
        }
    }
    
    private func handleMessageHistory(_ event: SocketEvent) {
        guard let data = event.data.first as? [String: Any],
              let messagesData = data["messages"] as? [[String: Any]] else {
            logger.error("Invalid message history data")
            isLoadingMore = false
            return
        }
        
        // Check if this is the end of messages (no more to load)
        _ = data["total"] as? Int
        let currentCount = data["count"] as? Int ?? messagesData.count
        let hasMore = data["hasMore"] as? Bool ?? (currentCount >= 20) // Assume has more if we got a full batch
        
        hasMoreMessages = hasMore
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: messagesData)
            let historyMessages = try JSONDecoder().decode([ChatHistoryMessage].self, from: jsonData)
            
            print("History messages: \(historyMessages)")
            
            // Convert ChatHistoryMessage to ChatMessage
            let convertedMessages: [ChatMessage] = historyMessages.map { historyMsg in
                ChatMessage(
                    id: historyMsg.id,
                    content: historyMsg.content,
                    senderId: historyMsg.senderId,
                    senderName: historyMsg.senderName,
                    senderAvatar: historyMsg.senderAvatar,
                    type: historyMsg.type,
                    timestamp: historyMsg.timestamp,
                    reactions: historyMsg.reactions,
                    roomId: historyMsg.roomId,
                    createdAt: ISO8601DateFormatter().string(from: historyMsg.date),
                    updatedAt: ISO8601DateFormatter().string(from: historyMsg.date),
                    deleted: false
                )
            }
            
            if isLoadingMore {
                // For load more, prepend older messages and filter duplicates
                let uniqueMessages = convertedMessages.filter { convertedMsg in
                    !messages.contains { $0.id == convertedMsg.id }
                }
                self.messages = uniqueMessages + self.messages
            } else {
                // For initial load, replace all messages
                self.messages = convertedMessages
            }
            
            self.messages.sort { $0.timestamp < $1.timestamp }
            
            logger.info("Loaded \(historyMessages.count) messages from history (hasMore: \(hasMore))")
            event.acknowledge()
            
        } catch {
            logger.error("Failed to decode message history: \(error.localizedDescription)")
        }
        
        isLoadingMore = false
    }
    
    private func handleUserJoinedChat(_ event: SocketEvent) {
        guard let data = event.data.first as? [String: Any] else {
            logger.error("Invalid user joined data")
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let user = try JSONDecoder().decode(ChatUser.self, from: jsonData)
            
            if !onlineUsers.contains(where: { $0.id == user.userId }) {
                onlineUsers.append(ChatUserInApp(id: user.userId, name: user.userName, isOnline: true))
            }
            
            logger.info("User joined chat: \(user.userName)")
            event.acknowledge()
            
        } catch {
            logger.error("Failed to decode user joined data: \(error.localizedDescription)")
        }
    }
    
    private func handleUserLeftChat(_ event: SocketEvent) {
        guard let data = event.data.first as? [String: Any],
              let userId = data["userId"] as? String else {
            logger.error("Invalid user left data")
            return
        }
        
        onlineUsers.removeAll { $0.id == userId }
        typingUsers.removeAll { $0 == userId }
        
        logger.info("User left chat: \(userId)")
        event.acknowledge()
    }
    
    private func handleUserStartedTyping(_ event: SocketEvent) {
        guard let data = event.data.first as? [String: Any],
              let userId = data["userId"] as? String,
              let userName = data["userName"] as? String else {
            logger.error("Invalid typing start data")
            return
        }
        
        if !typingUsers.contains(userId) {
            typingUsers.append(userId)
        }
        
        logger.debug("User started typing: \(userName)")
        event.acknowledge()
    }
    
    private func handleUserStoppedTyping(_ event: SocketEvent) {
        guard let data = event.data.first as? [String: Any],
              let userId = data["userId"] as? String else {
            logger.error("Invalid typing stop data")
            return
        }
        
        typingUsers.removeAll { $0 == userId }
        event.acknowledge()
    }
    
    private func handleMessageReactionUpdated(_ event: SocketEvent) {
        guard let data = event.data.first as? [String: Any],
              let messageId = data["messageId"] as? String,
              let reactions = data["reactions"] as? [String: Int] else {
            logger.error("Invalid reaction update data")
            return
        }
        
        // Update message reactions
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].reactions = reactions
        }
        
        logger.info("Updated reactions for message: \(messageId)")
        event.acknowledge()
    }
    
    private func handleChatRoomUpdated(_ event: SocketEvent) {
        guard let data = event.data.first as? [String: Any] else {
            logger.error("Invalid chat room update data")
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let roomData = try JSONDecoder().decode(ChatRoomUpdated.self, from: jsonData)
            let userService = UserService.shared
            let newUserIds = Set(roomData.onlineUsers)
            
            // Remove users who are no longer online
            onlineUsers.removeAll { !newUserIds.contains($0.id) }
            
            // For each userId, ensure we have a ChatUserInApp with name
            for userId in roomData.onlineUsers {
                if let existing = onlineUsers.first(where: { $0.id == userId && !$0.name.isEmpty }) {
                    // Already have user with name, skip
                    continue
                }
                // Add placeholder if not present
                if !onlineUsers.contains(where: { $0.id == userId }) {
                    onlineUsers.append(ChatUserInApp(id: userId, name: "", isOnline: true))
                }
                // Fetch user name if missing
                userService.findOne(id: userId)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] user in
                        guard let self = self else { return }
                        if let idx = self.onlineUsers.firstIndex(where: { $0.id == userId }) {
                            self.onlineUsers[idx] = ChatUserInApp(id: userId, name: user.name ?? user.email, isOnline: true)
                        }
                    })
                    .store(in: &cancellables)
            }
        } catch {
            print(String(describing: error))
        }

        logger.info("Chat room updated: \(data)")
        event.acknowledge()
    }
}
