//
//  UserService.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 30/8/25.
//

import Foundation
import Combine
import OSLog

class UserService: ObservableObject {
    static let shared = UserService()
    
    private let authManager = AuthenticationManager.shared
    private let logger = Logger(subsystem: "io.vn.eatwhat", category: "UserService")
    private let prefix = "user"
    
    // Cache for actual user data (value-based caching)
    private var userDataCache = [String: UserModel]()
    // Cache for ongoing requests to prevent duplicate API calls
    private var ongoingRequests = [String: AnyPublisher<UserModel, Error>]()
    private let cacheQueue = DispatchQueue(label: "userservice.cache", attributes: .concurrent)
    
    private init() {
        // Clear cache when tokens are cleared
        authManager.tokensClearedPublisher
            .sink { [weak self] in
                self?.clearCache()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Find a user by ID with caching
    func findOne(id: String) -> AnyPublisher<UserModel, Error> {
        return cacheQueue.sync {
            // First check if we have cached data
            if let cachedUser = userDataCache[id] {
                logger.debug("Returning cached user data for ID: \(id)")
                return Just(cachedUser)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            
            // Check if request is already in progress
            if let ongoingRequest = ongoingRequests[id] {
                logger.debug("Returning ongoing request for ID: \(id)")
                return ongoingRequest
            }
            
            // Create new request
            guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)/\(id)") else {
                logger.error("Invalid URL for user ID: \(id)")
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }
            
            logger.info("Fetching user with ID: \(id)")
            
            let publisher = authManager.authenticatedRequest(
                url: url,
                method: "GET",
                responseType: UserModel.self
            )
                .handleEvents(
                    receiveOutput: { [weak self] user in
                        self?.logger.info("Successfully fetched user: \(user.email)")
                        // Cache the actual user data
                        self?.cacheQueue.async(flags: .barrier) {
                            self?.userDataCache[id] = user
                        }
                    },
                    receiveCompletion: { [weak self] completion in
                        // Remove from ongoing requests after completion
                        self?.cacheQueue.async(flags: .barrier) {
                            self?.ongoingRequests.removeValue(forKey: id)
                        }
                        
                        if case .failure(let error) = completion {
                            self?.logger.error("Failed to fetch user with ID \(id): \(error.localizedDescription)")
                        } else {
                            self?.logger.debug("Completed user request for ID: \(id)")
                        }
                    }
                )
                .share() // Share the subscription among multiple subscribers
                .eraseToAnyPublisher()
            
            // Cache the ongoing request to prevent duplicates
            ongoingRequests[id] = publisher
            
            return publisher
        }
    }
    
    /// Create a new user
    func create(_ user: CreateUserDto) -> AnyPublisher<UserModel, Error> {
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)") else {
            logger.error("Invalid URL for creating user")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        logger.info("Creating new user with email: \(user.email)")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let body = try encoder.encode(user)
            
            return authManager.authenticatedRequest(
                url: url,
                method: "POST",
                body: body,
                responseType: UserModel.self
            )
            .handleEvents(
                receiveOutput: { [weak self] createdUser in
                    self?.logger.info("Successfully created user: \(createdUser.email)")
                    // Clear cache to ensure fresh data
                    self?.clearCache()
                },
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.logger.error("Failed to create user: \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
            
        } catch {
            logger.error("Failed to encode user data: \(error.localizedDescription)")
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    /// Update an existing user
    func update(_ user: UpdateUserDto) -> AnyPublisher<UserModel, Error> {
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)/\(user.id)") else {
            logger.error("Invalid URL for updating user with ID: \(user.id)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        logger.info("Updating user with ID: \(user.id)")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let body = try encoder.encode(user)
            
            return authManager.authenticatedRequest(
                url: url,
                method: "PUT",
                body: body,
                responseType: UserModel.self
            )
            .handleEvents(
                receiveOutput: { [weak self] updatedUser in
                    self?.logger.info("Successfully updated user: \(updatedUser.email)")
                    // Remove from cache to ensure fresh data on next request
                    self?.cacheQueue.async(flags: .barrier) {
                        self?.userDataCache.removeValue(forKey: user.id)
                    }
                },
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.logger.error("Failed to update user with ID \(user.id): \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
            
        } catch {
            logger.error("Failed to encode user update data: \(error.localizedDescription)")
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    /// Delete a user by ID
    func delete(id: String) -> AnyPublisher<Bool, Error> {
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)/\(id)") else {
            logger.error("Invalid URL for deleting user with ID: \(id)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        logger.info("Deleting user with ID: \(id)")
        
        var request = authManager.createAuthenticatedRequest(url: url, method: "DELETE")
        
        return authManager.withAutoTokenRefresh(
            originalPublisher: URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { data, response -> Bool in
                    if let httpResponse = response as? HTTPURLResponse {
                        self.logger.debug("Delete response status: \(httpResponse.statusCode)")
                        
                        if httpResponse.statusCode == 401 {
                            throw URLError(.userAuthenticationRequired)
                        }
                        
                        if (200...299).contains(httpResponse.statusCode) {
                            return true
                        } else {
                            throw URLError(.badServerResponse)
                        }
                    }
                    return false
                }
                .handleEvents(
                    receiveOutput: { [weak self] success in
                        if success {
                            self?.logger.info("Successfully deleted user with ID: \(id)")
                            // Remove from cache
                            self?.cacheQueue.async(flags: .barrier) {
                                self?.userDataCache.removeValue(forKey: id)
                            }
                        }
                    },
                    receiveCompletion: { [weak self] completion in
                        if case .failure(let error) = completion {
                            self?.logger.error("Failed to delete user with ID \(id): \(error.localizedDescription)")
                        }
                    }
                )
                .eraseToAnyPublisher()
        )
    }
    
    /// Query users with filters
    func query(_ queryDto: QueryUserDto) -> AnyPublisher<[UserModel], Error> {
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)/query") else {
            logger.error("Invalid URL for querying users")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        logger.info("Querying users with keyword: \(queryDto.keyword)")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let body = try encoder.encode(queryDto)
            
            return authManager.authenticatedRequest(
                url: url,
                method: "POST",
                body: body,
                responseType: [UserModel].self
            )
            .handleEvents(
                receiveOutput: { [weak self] users in
                    self?.logger.info("Successfully queried \(users.count) users")
                },
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.logger.error("Failed to query users: \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
            
        } catch {
            logger.error("Failed to encode query data: \(error.localizedDescription)")
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    // MARK: - Cache Management
    
    /// Clear the user cache
    func clearCache() {
        cacheQueue.async(flags: .barrier) { [weak self] in
            self?.userDataCache.removeAll()
            self?.logger.info("User cache cleared")
        }
    }
    
    /// Remove specific user from cache
    func removeCachedUser(id: String) {
        cacheQueue.async(flags: .barrier) { [weak self] in
            self?.userDataCache.removeValue(forKey: id)
            self?.logger.debug("Removed user \(id) from cache")
        }
    }
    
    /// Check if user is cached
    func isUserCached(id: String) -> Bool {
        return cacheQueue.sync {
            return userDataCache[id] != nil
        }
    }
}

// MARK: - Convenience Extensions

extension UserService {
    /// Get current user profile (requires user ID from auth context)
    func getCurrentUser() -> AnyPublisher<UserModel?, Error> {
        // This would typically get the current user ID from the auth token or user defaults
        // For now, return nil if no way to determine current user
        logger.warning("getCurrentUser called but no method to determine current user ID")
        return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    /// Refresh user data (bypass cache)
    func refreshUser(id: String) -> AnyPublisher<UserModel, Error> {
        // Remove from cache first
        removeCachedUser(id: id)
        // Then fetch fresh data
        return findOne(id: id)
    }
}
