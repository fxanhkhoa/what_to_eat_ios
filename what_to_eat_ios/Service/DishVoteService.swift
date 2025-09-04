//
//  DishVoteService.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 19/8/25.
//

import Foundation
import Combine
import OSLog

class DishVoteService {
    private let jsonDecoder: JSONDecoder
    private let urlSession: URLSession
    private let prefix = "dish-vote"
    private let authManager = AuthenticationManager.shared
    private let logger = Logger(subsystem: "io.vn.eatwhat", category: "DishVoteService")
    
    init(urlSession: URLSession = .shared) {
        // Create URL session with increased timeout and better configuration
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        configuration.waitsForConnectivity = true
        
        self.urlSession = urlSession
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        self.jsonDecoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Find All (with filtering and pagination)
    func findAll(filter: DishVoteFilter) -> AnyPublisher<APIPagination<DishVote>, Error> {
        // Check authentication first
        guard authManager.isAuthenticated else {
            return authManager.handleAuthenticationError()
        }
        
        // Check network connection
        guard authManager.isNetworkAvailable() else {
            return authManager.handleNetworkError()
        }
        
        // Convert DishVoteFilter to URL query parameters
        let queryItems = buildQueryItems(from: filter)
        
        // Create URL with query parameters
        var urlComponents = URLComponents(string: "\(APIConstants.baseURL)/\(prefix)")!
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            logger.error("Failed to create URL for findAll request")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        logger.info("Making authenticated API request to: \(url.absoluteString)")
        
        return authManager.authenticatedRequest(
            url: url,
            method: "GET",
            responseType: APIPagination<DishVote>.self
        )
        .handleEvents(
            receiveSubscription: { _ in
                self.logger.info("Starting authenticated findAll request")
            },
            receiveOutput: { response in
                self.logger.info("Received \(response.count) dish votes")
            },
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.logger.error("findAll request failed: \(error.localizedDescription)")
                } else {
                    self.logger.info("findAll request completed successfully")
                }
            },
            receiveCancel: {
                self.logger.info("findAll request was cancelled")
            }
        )
        .eraseToAnyPublisher()
    }
    
    // MARK: - Find By ID
    func findById(id: String) -> AnyPublisher<DishVote, Error> {
        guard authManager.isAuthenticated else {
            return authManager.handleAuthenticationError()
        }
        
        guard authManager.isNetworkAvailable() else {
            return authManager.handleNetworkError()
        }
        
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)/\(id)") else {
            logger.error("Failed to create URL for findById request")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        logger.info("Making authenticated findById API request to: \(url.absoluteString)")
        
        return authManager.authenticatedRequest(
            url: url,
            method: "GET",
            responseType: DishVote.self
        )
        .handleEvents(
            receiveOutput: { dishVote in
                self.logger.info("Successfully retrieved dish vote with ID: \(dishVote.id)")
            },
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.logger.error("findById request failed: \(error.localizedDescription)")
                }
            }
        )
        .eraseToAnyPublisher()
    }
    
    // MARK: - Create
    func create(dto: CreateDishVoteDto) -> AnyPublisher<DishVote, Error> {
        guard authManager.isAuthenticated else {
            return authManager.handleAuthenticationError()
        }
        
        guard authManager.isNetworkAvailable() else {
            return authManager.handleNetworkError()
        }
        
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)") else {
            logger.error("Failed to create URL for create request")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        logger.info("Making authenticated create API request to: \(url.absoluteString)")
        
        do {
            let jsonData = try JSONEncoder().encode(dto)
            
            return authManager.authenticatedRequest(
                url: url,
                method: "POST",
                body: jsonData,
                responseType: DishVote.self
            )
            .handleEvents(
                receiveOutput: { dishVote in
                    self.logger.info("Successfully created dish vote with ID: \(dishVote.id)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.logger.error("create request failed: \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
        } catch {
            logger.error("Failed to encode CreateDishVoteDto: \(error.localizedDescription)")
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    // MARK: - Update
    func update(dto: UpdateDishVoteDto) -> AnyPublisher<DishVote, Error> {
        guard authManager.isAuthenticated else {
            return authManager.handleAuthenticationError()
        }
        
        guard authManager.isNetworkAvailable() else {
            return authManager.handleNetworkError()
        }
        
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)/\(dto.id)") else {
            logger.error("Failed to create URL for update request")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        logger.info("Making authenticated update API request to: \(url.absoluteString)")
        
        do {
            let jsonData = try JSONEncoder().encode(dto)
            
            return authManager.authenticatedRequest(
                url: url,
                method: "PATCH",
                body: jsonData,
                responseType: DishVote.self
            )
            .handleEvents(
                receiveOutput: { dishVote in
                    self.logger.info("Successfully updated dish vote with ID: \(dishVote.id)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.logger.error("update request failed: \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
        } catch {
            logger.error("Failed to encode UpdateDishVoteDto: \(error.localizedDescription)")
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    // MARK: - Delete
    func delete(id: String) -> AnyPublisher<DishVote, Error> {
        guard authManager.isAuthenticated else {
            return authManager.handleAuthenticationError()
        }
        
        guard authManager.isNetworkAvailable() else {
            return authManager.handleNetworkError()
        }
        
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)/\(id)") else {
            logger.error("Failed to create URL for delete request")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        logger.info("Making authenticated delete API request to: \(url.absoluteString)")
        
        return authManager.authenticatedRequest(
            url: url,
            method: "DELETE",
            responseType: DishVote.self
        )
        .handleEvents(
            receiveOutput: { dishVote in
                self.logger.info("Successfully deleted dish vote with ID: \(dishVote.id)")
            },
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.logger.error("delete request failed: \(error.localizedDescription)")
                }
            }
        )
        .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    // Helper method to convert DishVoteFilter to URLQueryItems
    private func buildQueryItems(from filter: DishVoteFilter) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        
        // Add pagination parameters
        if let page = filter.page {
            queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
        }
        
        if let limit = filter.limit {
            queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        }
        
        // Add sorting parameters
        if let sortBy = filter.sortBy {
            queryItems.append(URLQueryItem(name: "sortBy", value: sortBy))
        }
        
        if let sortOrder = filter.sortOrder {
            queryItems.append(URLQueryItem(name: "sortOrder", value: sortOrder))
        }
        
        // Add filtering parameters
        if let keyword = filter.keyword, !keyword.isEmpty {
            queryItems.append(URLQueryItem(name: "keyword", value: keyword))
        }
        
        return queryItems
    }
}
