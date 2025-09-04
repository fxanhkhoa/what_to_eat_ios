//
//  SocketIOManager.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 24/8/25.
//

import Foundation
import SocketIO
import Combine
import OSLog

/// Centralized Socket.IO manager for real-time communication
@MainActor
class SocketIOManager: ObservableObject {
    static let shared = SocketIOManager()
    
    private let logger = Logger(subsystem: "io.vn.eatwhat", category: "SocketIOManager")
    private let authManager = AuthenticationManager.shared
    private let networkMonitor = NetworkMonitor.shared
    
    // MARK: - Published Properties
    @Published var isConnected = false
    @Published var connectionStatus: SocketConnectionStatus = .disconnected
    @Published var lastError: String?
    
    // MARK: - Private Properties
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    private var cancellables = Set<AnyCancellable>()
    private var reconnectTimer: Timer?
    private var connectionAttempts = 0
    private let maxReconnectAttempts = 5
    private let reconnectDelay: TimeInterval = 2.0
    
    // Event publishers for reactive programming
    private let eventSubject = PassthroughSubject<SocketEvent, Never>()
    
    /// Publisher for socket events
    var eventPublisher: AnyPublisher<SocketEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    /// Expose socket for debugging purposes only
    var debugSocket: SocketIOClient? {
        return self.socket
    }
    
    private init() {
        setupAuthenticationObserver()
        setupNetworkObserver()
        logger.info("SocketIOManager initialized")
    }
    
    // MARK: - Connection Management
    
    /// Connect to the Socket.IO server
    func connect() {
        guard authManager.isAuthenticated else {
            logger.warning("Cannot connect to socket - user not authenticated")
            lastError = "Authentication required"
            return
        }
        
        guard networkMonitor.isConnected else {
            logger.warning("Cannot connect to socket - no network connection")
            lastError = "No network connection"
            return
        }
        
        if isConnected {
            logger.info("Socket already connected")
            return
        }
        
        setupSocket()
        socket?.connect()
        connectionStatus = .connecting
        logger.info("Attempting to connect to Socket.IO server")
    }
    
    /// Disconnect from the Socket.IO server
    func disconnect() {
        socket?.disconnect()
        connectionStatus = .disconnected
        cancelReconnectTimer()
        logger.info("Disconnected from Socket.IO server")
    }
    
    /// Force reconnect to the Socket.IO server
    func reconnect() {
        disconnect()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.connect()
        }
    }
    
    // MARK: - Message Sending
    
    /// Send a message to a specific event with JSON string data
    func emit(_ event: String, data: String) {
        guard isConnected else {
            logger.warning("Cannot emit event '\(event)' - socket not connected")
            lastError = "Socket not connected"
            return
        }
        
        logger.debug("Emitting event: \(event) with JSON string data")
        socket?.emit(event, data)
        logger.debug("Emitted event: \(event)")
    }
    
    /// Send a message to a specific event with two JSON string parameters
    func emit(_ event: String, data1: Data, data2: Data) {
        guard isConnected else {
            logger.warning("Cannot emit event '\(event)' - socket not connected")
            lastError = "Socket not connected"
            return
        }
        
        logger.debug("Emitting event: \(event) with 2 JSON string parameters")
        socket?.emit(event, data1, data2)
        logger.debug("Emitted event: \(event)")
    }
    
    /// Send a message to a specific event (legacy dictionary support)
    func emit(_ event: String, data: [String: Any]) {
        guard isConnected else {
            logger.warning("Cannot emit event '\(event)' - socket not connected")
            lastError = "Socket not connected"
            return
        }
        
        logger.debug("Emitting event: \(event) with data: \(data)")
        socket?.emit(event, data)
        logger.debug("Emitted event: \(event) with dictionary data")
    }
    
    func emit(_ event: String, data1: [String: Any], data2: [String: Any]) {
        guard isConnected else {
            logger.warning("Cannot emit event '\(event)' - socket not connected")
            lastError = "Socket not connected"
            return
        }
        
        logger.debug("Emitting event: \(event) with data: \(data1), \(data2)")
        socket?.emit(event, data1, data2)
        logger.debug("Emitted event: \(event) with dictionary data")
    }
    
    /// Send a message with acknowledgment
    func emitWithAck(_ event: String, data: [String: Any], timeout: TimeInterval = 5.0) -> AnyPublisher<[Any], Error> {
        guard isConnected else {
            logger.warning("Cannot emit event '\(event)' with ack - socket not connected")
            return Fail(error: SocketError.notConnected).eraseToAnyPublisher()
        }
        
        return Future { promise in
            self.socket?.emitWithAck(event, data).timingOut(after: timeout) { data in
                promise(.success(data))
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - Event Subscription
    
    /// Subscribe to a socket event
    func subscribe(to event: String) -> AnyPublisher<SocketEvent, Never> {
        print("Subscribing to event: \(event)")
        // Add listener for the event
        if (socket == nil) {
            logger.warning("Socket is not initialized. Call connect() first.")
            return Empty().eraseToAnyPublisher()
        }
        socket?.on(event) { [weak self] data, ack in
            print("Received event: \(event) with data: \(data)")
            let socketEvent = SocketEvent(name: event, data: data, ack: ack)
            self?.eventSubject.send(socketEvent)
            self?.logger.debug("Received event: \(event)")
        }
        
        // Return filtered publisher for this specific event
        return eventPublisher
            .filter { $0.name == event }
            .eraseToAnyPublisher()
    }
    
    /// Unsubscribe from a socket event
    func unsubscribe(from event: String) {
        socket?.off(event)
        logger.debug("Unsubscribed from event: \(event)")
    }
    
    /// Join a room
    func joinRoom(_ room: String, data: [String: Any] = [:]) {
        var joinData = data
        joinData["roomID"] = room
        emit("join-room", data: joinData)
        logger.info("Joining room: \(room)")
    }
    
    /// Leave a room
    func leaveRoom(_ room: String, data: [String: Any] = [:]) {
        var leaveData = data
        leaveData["room"] = room
        emit("leave-room", data: leaveData)
        logger.info("Leaving room: \(room)")
    }
    
    // MARK: - Private Methods
    
    private func setupSocket() {
        guard let url = URL(string: APIConstants.baseURL) else {
            logger.error("Invalid Socket.IO URL")
            lastError = "Invalid server URL"
            return
        }
        
        // iOS-optimized socket configuration to prevent SO_NOWAKEFROMSLEEP errors
        var config: SocketIOClientConfiguration = [
            .log(false),
            .compress,
            .reconnects(true),
            .reconnectAttempts(maxReconnectAttempts),
            .reconnectWait(Int(reconnectDelay)),
            .forceWebsockets(true),     // Use WebSockets for better iOS compatibility
            .secure(url.scheme == "https"), // Use secure connection based on URL scheme
            .selfSigned(false),         // Don't allow self-signed certificates in production
            .connectParams(["EIO": "4"]) // Ensure compatibility with Socket.IO v4
        ]
        
        // Add authentication headers if available
        if let token = authManager.currentToken {
            config.insert(.extraHeaders(["Authorization": "Bearer \(token)"]))
        }
        
        // Create manager with optimized configuration
        manager = SocketManager(
            socketURL: url,
            config: config
        )
        
        socket = manager?.defaultSocket
        setupSocketHandlers()
    }
    
    private func setupSocketHandlers() {
        guard let socket = socket else { return }
        
        // Connection events
        socket.on(clientEvent: .connect) { [weak self] _, _ in
            Task { @MainActor in
                self?.handleConnected()
            }
        }
        
        socket.on(clientEvent: .disconnect) { [weak self] data, _ in
            Task { @MainActor in
                self?.handleDisconnected(reason: data.first as? String)
            }
        }
        
        socket.on(clientEvent: .error) { [weak self] data, _ in
            Task { @MainActor in
                self?.handleError(data: data)
            }
        }
        
        socket.on(clientEvent: .reconnect) { [weak self] _, _ in
            Task { @MainActor in
                self?.handleReconnected()
            }
        }
        
        socket.on(clientEvent: .reconnectAttempt) { [weak self] data, _ in
            Task { @MainActor in
                self?.handleReconnectAttempt(attempt: data.first as? Int ?? 0)
            }
        }
        
        // Authentication events
        socket.on("auth_error") { [weak self] data, _ in
            Task { @MainActor in
                self?.handleAuthError(data: data)
            }
        }
        
        socket.on("auth_success") { [weak self] _, _ in
            Task { @MainActor in
                self?.handleAuthSuccess()
            }
        }
    }
    
    private func handleConnected() {
        isConnected = true
        connectionStatus = .connected
        connectionAttempts = 0
        lastError = nil
        cancelReconnectTimer()
        logger.info("Successfully connected to Socket.IO server")
        
        // Emit authentication if needed
        if let token = authManager.currentToken {
            emit("authenticate", data: ["token": token])
        }
    }
    
    private func handleDisconnected(reason: String?) {
        isConnected = false
        connectionStatus = .disconnected
        let disconnectReason = reason ?? "Unknown reason"
        logger.info("Disconnected from Socket.IO server. Reason: \(disconnectReason)")
        
        // Handle reconnection based on reason
        if disconnectReason != "io client disconnect" && networkMonitor.isConnected {
            scheduleReconnect()
        }
    }
    
    private func handleError(data: [Any]) {
        let errorMessage = data.first as? String ?? "Unknown socket error"
        lastError = errorMessage
        logger.error("Socket error: \(errorMessage)")
    }
    
    private func handleReconnected() {
        logger.info("Successfully reconnected to Socket.IO server")
        connectionAttempts = 0
    }
    
    private func handleReconnectAttempt(attempt: Int) {
        connectionAttempts = attempt
        logger.info("Reconnection attempt #\(attempt)")
    }
    
    private func handleAuthError(data: [Any]) {
        let errorMessage = data.first as? String ?? "Authentication failed"
        lastError = errorMessage
        logger.error("Socket authentication error: \(errorMessage)")
        
        // Clear tokens if authentication fails
        authManager.clearTokens()
        disconnect()
    }
    
    private func handleAuthSuccess() {
        logger.info("Socket authentication successful")
        lastError = nil
    }
    
    private func scheduleReconnect() {
        guard connectionAttempts < maxReconnectAttempts else {
            logger.error("Max reconnection attempts reached")
            lastError = "Max reconnection attempts reached"
            return
        }
        
        cancelReconnectTimer()
        
        let delay = reconnectDelay * pow(2.0, Double(connectionAttempts)) // Exponential backoff
        logger.info("Scheduling reconnect in \(delay) seconds")
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.connect()
            }
        }
    }
    
    private func cancelReconnectTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
    
    private func setupAuthenticationObserver() {
        // Connect when user logs in
        authManager.tokensClearedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.disconnect()
                self?.logger.info("Disconnected socket due to token clearing")
            }
            .store(in: &cancellables)
    }
    
    private func setupNetworkObserver() {
        // Handle network changes
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                if isConnected && self?.authManager.isAuthenticated == true && !self!.isConnected {
                    self?.connect()
                } else if !isConnected {
                    self?.disconnect()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Supporting Types

enum SocketConnectionStatus {
    case disconnected
    case connecting
    case connected
    case reconnecting
    
    var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .reconnecting: return "Reconnecting"
        }
    }
}

struct SocketEvent {
    let name: String
    let data: [Any]
    let ack: SocketAckEmitter?
    let timestamp: Date = Date()
    
    /// Acknowledge the event
    func acknowledge(with data: [Any] = []) {
        ack?.with(data)
    }
}

enum SocketError: Error, LocalizedError {
    case notConnected
    case authenticationRequired
    case timeout
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "Socket is not connected"
        case .authenticationRequired:
            return "Authentication required for socket connection"
        case .timeout:
            return "Socket operation timed out"
        case .invalidData:
            return "Invalid data received from socket"
        }
    }
}
