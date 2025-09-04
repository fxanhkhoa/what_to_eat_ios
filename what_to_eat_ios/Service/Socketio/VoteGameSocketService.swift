//
//  VoteGameSocketService.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 24/8/25.
//

import Foundation
import Combine
import OSLog

/// Service for handling vote game real-time events via Socket.IO
@MainActor
class VoteGameSocketService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var activeVoteGames: [DishVote] = []
    @Published var voteUpdates: [VoteUpdate] = []
    @Published var newVoteGame: DishVote?
    @Published var voteGameDeleted: String?
    @Published var connectionError: String?
    
    // MARK: - Private Properties
    private let socketManager = SocketIOManager.shared
    private let logger = Logger(subsystem: "io.vn.eatwhat", category: "VoteGameSocketService")
    private var cancellables = Set<AnyCancellable>()
    private var subscribedRooms: Set<String> = []
    private var isSubscriptionsSetup = false
    
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
    
    /// Subscribe to a specific vote game room for real-time updates
    func subscribeToVoteGame(_ voteGameId: String) {
        let roomName = voteGameId
        
        guard !subscribedRooms.contains(roomName) else {
            logger.info("Already subscribed to vote game: \(voteGameId)")
            return
        }
        
        // Ensure socket is connected and subscriptions are setup
        ensureConnectionAndSubscriptions()
        
        socketManager.joinRoom(roomName, data: ["roomID": voteGameId])
        subscribedRooms.insert(roomName)
        logger.info("Subscribed to vote game room: \(roomName)")
    }
    
    /// Unsubscribe from a specific vote game room
    func unsubscribeFromVoteGame(_ voteGameId: String) {
        let roomName = voteGameId
        
        guard subscribedRooms.contains(roomName) else {
            logger.info("Not subscribed to vote game: \(voteGameId)")
            return
        }
        
        socketManager.leaveRoom(roomName, data: ["roomID": voteGameId])
        subscribedRooms.remove(roomName)
        logger.info("Unsubscribed from vote game room: \(roomName)")
    }
    
    /// Subscribe to general vote game events (new games, deletions, etc.)
    func subscribeToGeneralVoteGameEvents() {
        let roomName = "vote_games_general"
        
        guard !subscribedRooms.contains(roomName) else {
            logger.info("Already subscribed to general vote game events")
            return
        }
        
        // Ensure socket is connected and subscriptions are setup
        ensureConnectionAndSubscriptions()
        
        socketManager.joinRoom(roomName)
        subscribedRooms.insert(roomName)
        logger.info("Subscribed to general vote game events")
    }
    
    /// Unsubscribe from all vote game rooms
    func unsubscribeFromAll() {
        for room in subscribedRooms {
            socketManager.leaveRoom(room)
        }
        subscribedRooms.removeAll()
        logger.info("Unsubscribed from all vote game rooms")
    }
    
    /// Submit a vote for a dish
    func submitVote(voteData: DishVoteSubmit, options: VoteOptions) {
        logger.info("Submitting vote for dish: \(voteData.slug) in vote game: \(options.roomID)")
        
        // Convert Swift objects to JSON strings
        do {
            let voteDataDict = try convertToDict(voteData)
            let optionsDict = try convertToDict(options)
            
            socketManager.emit("dish-vote-update", data1: voteDataDict, data2: optionsDict)
            logger.info("Successfully submitted vote for dish: \(voteData.slug) in vote game: \(options.roomID)")
        } catch {
            logger.error("Failed to convert vote data to JSON: \(error.localizedDescription)")
        }
    }
    
    /// Create a new vote game and emit to all subscribers
    func createVoteGame(_ voteGame: DishVote) {
        do {
            let voteGameJSON = try convertToJSON(voteGame)
            socketManager.emit("create_vote_game", data: voteGameJSON)
            logger.info("Created new vote game: \(voteGame.id)")
        } catch {
            logger.error("Failed to convert vote game to JSON: \(error.localizedDescription)")
        }
    }
    
    /// Delete a vote game and notify all subscribers
    func deleteVoteGame(_ voteGameId: String) {
        let deleteData = DeleteVoteGameData(voteGameId: voteGameId, timestamp: Date().timeIntervalSince1970)
        
        do {
            let deleteDataJSON = try convertToJSON(deleteData)
            socketManager.emit("delete_vote_game", data: deleteDataJSON)
            logger.info("Deleted vote game: \(voteGameId)")
        } catch {
            logger.error("Failed to convert delete data to JSON: \(error.localizedDescription)")
        }
    }
    
    /// Enable debug logging to troubleshoot socket events
    func enableDebugLogging() {
        logger.info("Debug logging enabled for VoteGameSocketService")
        
        // Also enable logging in the socket manager temporarily
        socketManager.debugSocket?.on("*") { [weak self] event, data in
            self?.logger.debug("🔍 Raw Socket Event: \(event) with data: \(data)")
        }
    }
    
    /// Disable debug logging
    func disableDebugLogging() {
        logger.info("Debug logging disabled for VoteGameSocketService")
        socketManager.debugSocket?.off("*")
    }
    
    /// Get current connection status for debugging
    func getDebugInfo() -> [String: Any] {
        return [
            "isConnected": socketManager.isConnected,
            "connectionStatus": socketManager.connectionStatus.description,
            "subscribedRooms": Array(subscribedRooms),
            "lastError": socketManager.lastError ?? "None",
            "voteUpdatesCount": voteUpdates.count,
            "activeVoteGamesCount": activeVoteGames.count
        ]
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
        
        logger.info("Setting up socket subscriptions for vote game events")
        // Subscribe to vote updates
        socketManager.subscribe(to: "dish-vote-update-client")
            .sink { [weak self] event in
                self?.handleVoteUpdate(event)
            }
            .store(in: &cancellables)
        
        // Subscribe to new vote games
        socketManager.subscribe(to: "vote_game_created")
            .sink { [weak self] event in
                self?.handleNewVoteGame(event)
            }
            .store(in: &cancellables)
        
        // Subscribe to vote game deletions
        socketManager.subscribe(to: "vote_game_deleted")
            .sink { [weak self] event in
                self?.handleVoteGameDeleted(event)
            }
            .store(in: &cancellables)
        
        // Subscribe to vote game updates (title, description changes)
        socketManager.subscribe(to: "vote_game_updated")
            .sink { [weak self] event in
                self?.handleVoteGameUpdated(event)
            }
            .store(in: &cancellables)
        
        // Subscribe to user joined/left events
        socketManager.subscribe(to: "user_joined_vote")
            .sink { [weak self] event in
                self?.handleUserJoinedVote(event)
            }
            .store(in: &cancellables)
        
        socketManager.subscribe(to: "user_left_vote")
            .sink { [weak self] event in
                self?.handleUserLeftVote(event)
            }
            .store(in: &cancellables)
            
        logger.info("Vote game socket subscriptions setup complete")
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
                    self?.rejoinRoomsAfterReconnection()
                } else {
                    self?.connectionError = "Socket disconnected"
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
    
    private func rejoinRoomsAfterReconnection() {
        // Rejoin all previously subscribed rooms after reconnection
        let roomsToRejoin = Array(subscribedRooms)
        subscribedRooms.removeAll()
        
        for room in roomsToRejoin {
            if room == "vote_games_general" {
                subscribeToGeneralVoteGameEvents()
            } else {
                // Assume it's a vote game ID
                subscribeToVoteGame(room)
            }
        }
        
        logger.info("Rejoined \(roomsToRejoin.count) rooms after reconnection")
    }
    
    // MARK: - Event Handlers
    
    private func handleVoteUpdate(_ event: SocketEvent) {
        logger.info("Raw vote update event received with \(event.data.count) items")
        
        // Log the raw data for debugging
//        for (index, item) in event.data.enumerated() {
//            logger.info("Event data[\(index)]: \(String(describing: item))")
//        }
        
        // Try to handle different possible data structures
        if let data = event.data.first as? [String: Any] {
//            logger.info("Received vote update as dictionary: \(data)")
            logger.info("Received vote update as dictionary:")
            handleVoteUpdateFromDictionary(data, event: event)
        } else if let dataArray = event.data as? [[String: Any]], !dataArray.isEmpty {
            logger.info("Received vote update as array of dictionaries")
            for data in dataArray {
                handleVoteUpdateFromDictionary(data, event: event)
            }
        } else if let voteUpdate = event.data.first as? VoteUpdate {
            logger.info("Received vote update as VoteUpdate object: \(String(describing: voteUpdate))")
            voteUpdates.append(voteUpdate)
            event.acknowledge()
        } else {
            // Log what we actually received for debugging
            let dataTypes = event.data.map { String(describing: type(of: $0)) }
            logger.error("Unexpected vote update data format. Received types: \(dataTypes)")
            logger.error("Raw event data: \(String(describing: event.data))")
            
            // Try to convert whatever we received to a readable format
            if let jsonData = try? JSONSerialization.data(withJSONObject: event.data),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                logger.error("Event data as JSON: \(jsonString)")
            }
        }
    }
    
    private func handleVoteUpdateFromDictionary(_ data: [String: Any], event: SocketEvent) {
        do {
            // First try to decode as VoteUpdate
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            
            // Try VoteUpdate first
            if let voteUpdate = try? JSONDecoder().decode(VoteUpdate.self, from: jsonData) {
                voteUpdates.append(voteUpdate)
                logger.info("Successfully decoded as VoteUpdate: \(String(describing: voteUpdate))")
                event.acknowledge()
                return
            }
            
            // Try DishVote if VoteUpdate fails
            if let dishVote = try? JSONDecoder().decode(DishVote.self, from: jsonData) {
                // Update the active vote games list
                if let index = activeVoteGames.firstIndex(where: { $0.id == dishVote.id }) {
                    activeVoteGames[index] = dishVote
                    logger.info("Successfully updated DishVote: \(dishVote.id)")
                } else {
                    activeVoteGames.append(dishVote)
                    logger.info("Added new DishVote: \(dishVote.id)")
                }
                newVoteGame = dishVote
                event.acknowledge()
                return
            }
            
            // If both fail, create a manual VoteUpdate from the raw data
            if let voteGameId = data["voteGameId"] as? String ?? data["id"] as? String,
               let dishSlug = data["dishSlug"] as? String ?? data["slug"] as? String {
                
                let voteCount = data["voteCount"] as? Int ?? data["votes"] as? Int ?? 0
                let manualUpdate = VoteUpdate(
                    voteGameId: voteGameId,
                    dishSlug: dishSlug,
                    voteCount: voteCount,
                    timestamp: Date().timeIntervalSince1970
                )
                
                voteUpdates.append(manualUpdate)
                logger.info("Created manual VoteUpdate: \(String(describing: manualUpdate))")
                event.acknowledge()
                return
            }
            
            // Last resort - just log the received data structure
            logger.warning("Could not decode vote update. Available keys: \(data.keys.sorted())")
            for (key, value) in data {
                logger.info("  \(key): \(String(describing: value)) (type: \(String(describing: type(of: value))))")
            }
            
        } catch {
            logger.error("Failed to process vote update dictionary: \(error.localizedDescription)")
            logger.error("Data: \(String(describing: data))")
        }
    }
    
    private func handleNewVoteGame(_ event: SocketEvent) {
        guard let data = event.data.first as? [String: Any] else {
            logger.error("Invalid new vote game data")
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let voteGame = try JSONDecoder().decode(DishVote.self, from: jsonData)
            
            newVoteGame = voteGame
            activeVoteGames.append(voteGame)
            logger.info("Received new vote game: \(voteGame.id)")
            
            event.acknowledge()
            
        } catch {
            logger.error("Failed to decode new vote game: \(error.localizedDescription)")
        }
    }
    
    private func handleVoteGameDeleted(_ event: SocketEvent) {
        guard let data = event.data.first as? [String: Any],
              let voteGameId = data["voteGameId"] as? String else {
            logger.error("Invalid vote game deletion data")
            return
        }
        
        voteGameDeleted = voteGameId
        activeVoteGames.removeAll { $0.id == voteGameId }
        logger.info("Vote game deleted: \(voteGameId)")
        
        event.acknowledge()
    }
    
    private func handleVoteGameUpdated(_ event: SocketEvent) {
        guard let data = event.data.first as? [String: Any] else {
            logger.error("Invalid vote game update data")
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let updatedVoteGame = try JSONDecoder().decode(DishVote.self, from: jsonData)
            
            // Update the vote game in the active list
            if let index = activeVoteGames.firstIndex(where: { $0.id == updatedVoteGame.id }) {
                activeVoteGames[index] = updatedVoteGame
                logger.info("Updated vote game: \(updatedVoteGame.id)")
            }
            
            event.acknowledge()
            
        } catch {
            logger.error("Failed to decode updated vote game: \(error.localizedDescription)")
        }
    }
    
    private func handleUserJoinedVote(_ event: SocketEvent) {
        guard let data = event.data.first as? [String: Any],
              let voteGameId = data["voteGameId"] as? String,
              let userName = data["userName"] as? String else {
            logger.error("Invalid user joined data")
            return
        }
        
        logger.info("User \(userName) joined vote game: \(voteGameId)")
        event.acknowledge()
    }
    
    private func handleUserLeftVote(_ event: SocketEvent) {
        guard let data = event.data.first as? [String: Any],
              let voteGameId = data["voteGameId"] as? String,
              let userName = data["userName"] as? String else {
            logger.error("Invalid user left data")
            return
        }
        
        logger.info("User \(userName) left vote game: \(voteGameId)")
        event.acknowledge()
    }
    
    // MARK: - Helper Methods
    
    private func convertToJSON<T: Codable>(_ object: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(object)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw NSError(domain: "VoteGameSocketService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON data to string"])
        }
        return jsonString
    }
    
    private func convertToDict<T: Codable>(_ object: T) throws -> [String: Any] {
        let jsonData = try JSONEncoder().encode(object)
        guard let dictionary = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw NSError(domain: "VoteGameSocketService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert object to dictionary"])
        }
        return dictionary
    }
    
    private func encodeVoteGameToDict(_ voteGame: DishVote) -> [String: Any] {
        do {
            return try convertToDict(voteGame)
        } catch {
            logger.error("Failed to encode vote game: \(error.localizedDescription)")
            return [:]
        }
    }
}

// MARK: - Supporting Models

struct VoteUpdate: Codable {
    let voteGameId: String
    let dishSlug: String
    let voteCount: Int
    let userVote: Bool?
    let anonymousVote: Bool?
    let timestamp: TimeInterval
    let userName: String?
    
    // Alternative initializer for manual creation
    init(voteGameId: String, dishSlug: String, voteCount: Int, timestamp: TimeInterval = Date().timeIntervalSince1970, userVote: Bool? = nil, anonymousVote: Bool? = nil, userName: String? = nil) {
        self.voteGameId = voteGameId
        self.dishSlug = dishSlug
        self.voteCount = voteCount
        self.timestamp = timestamp
        self.userVote = userVote
        self.anonymousVote = anonymousVote
        self.userName = userName
    }
}

struct DeleteVoteGameData: Codable {
    let voteGameId: String
    let timestamp: TimeInterval
}
