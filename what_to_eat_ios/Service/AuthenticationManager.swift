//
//  AuthenticationManager.swift
//  what_to_eat_ios
//
//  Created by System on 21/8/25.
//

import Foundation
import Combine
import OSLog

/// Centralized authentication manager for handling tokens and authenticated requests
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    private let logger = Logger(subsystem: "io.vn.eatwhat", category: "AuthenticationManager")
    private let networkMonitor = NetworkMonitor.shared
    
    // MARK: - Token Management
    
    /// Current access token
    var currentToken: String? {
        return UserDefaults.standard.string(forKey: "auth_token")
    }
    
    /// Current refresh token
    var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    /// Check if user is authenticated (has valid token)
    var isAuthenticated: Bool {
        return currentToken != nil
    }
    
    private init() {}
    
    // MARK: - Token Storage
    
    /// Save authentication tokens
    func saveTokens(accessToken: String, refreshToken: String) {
        UserDefaults.standard.set(accessToken, forKey: "auth_token")
        UserDefaults.standard.set(refreshToken, forKey: "refresh_token")
        logger.info("Authentication tokens saved successfully")
    }
    
    /// Clear all authentication tokens
    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        logger.info("Authentication tokens cleared")
    }
    
    // MARK: - Request Authentication
    
    /// Create an authenticated URLRequest with bearer token
    func createAuthenticatedRequest(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue(APIConstants.Headers.applicationJSON, forHTTPHeaderField: APIConstants.Headers.contentType)
        request.timeoutInterval = 30.0
        
        // Add Authorization header with bearer token
        if let token = currentToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            logger.debug("Added bearer token to request: \(url.absoluteString)")
        } else {
            logger.warning("No authentication token available for request: \(url.absoluteString)")
        }
        
        return request
    }
    
    /// Check if the request requires authentication
    func requiresAuthentication() -> Bool {
        return isAuthenticated
    }
    
    /// Handle authentication errors for API calls
    func handleAuthenticationError<T>() -> AnyPublisher<T, Error> {
        logger.warning("Authentication required but no token available")
        return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
    }
    
    // MARK: - Token Refresh
    
    /// Refresh authentication token when it expires
    func refreshAuthToken() -> AnyPublisher<Bool, Error> {
        guard let refreshToken = self.refreshToken else {
            logger.error("No refresh token available for token refresh")
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        
        guard networkMonitor.isConnected else {
            logger.error("No network connection available for token refresh")
            return Fail(error: URLError(.notConnectedToInternet)).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "\(APIConstants.baseURL)/auth/refresh") else {
            logger.error("Invalid URL for token refresh endpoint")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        logger.info("Attempting to refresh authentication token")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(APIConstants.Headers.applicationJSON, forHTTPHeaderField: APIConstants.Headers.contentType)
        request.timeoutInterval = 30.0
        
        let refreshBody = ["refreshToken": refreshToken]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: refreshBody)
        } catch {
            logger.error("Failed to encode refresh token request: \(error.localizedDescription)")
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ResultToken.self, decoder: createJSONDecoder())
            .map { [weak self] result in
                // Save new tokens
                self?.saveTokens(accessToken: result.token, refreshToken: result.refreshToken)
                self?.logger.info("Successfully refreshed authentication token")
                return true
            }
            .catch { [weak self] error -> AnyPublisher<Bool, Error> in
                self?.logger.error("Token refresh failed: \(error.localizedDescription)")
                // If refresh fails, clear all tokens
                self?.clearTokens()
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Authenticated Request Wrapper
    
    /// Wrap any API publisher with automatic token refresh on 401 errors
    func withAutoTokenRefresh<T>(originalPublisher: AnyPublisher<T, Error>) -> AnyPublisher<T, Error> {
        return originalPublisher
            .catch { [weak self] error -> AnyPublisher<T, Error> in
                guard let self = self else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                // Check if error is 401 Unauthorized or token-related
                if self.isTokenExpiredError(error) {
                    self.logger.info("Token expired, attempting automatic refresh...")
                    return self.refreshAuthToken()
                        .flatMap { success -> AnyPublisher<T, Error> in
                            if success {
                                self.logger.info("Token refreshed successfully, retrying original request")
                                // Retry the original request with new token
                                return originalPublisher
                            } else {
                                self.logger.error("Token refresh failed, unable to retry request")
                                return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
                            }
                        }
                        .eraseToAnyPublisher()
                } else {
                    // Not a token error, pass through original error
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    /// Check if an error indicates an expired or invalid token
    private func isTokenExpiredError(_ error: Error) -> Bool {
        // Check for 401 Unauthorized status code
        if let urlError = error as? URLError {
            return urlError.code == .userAuthenticationRequired
        }
        
        // Check for HTTP 401 response
        if let decodingError = error as? DecodingError {
            // Sometimes 401 responses come as decoding errors if the response format is different
            return false // We'll rely on URLError for now
        }
        
        // You can add more specific error checking here based on your API's error format
        return false
    }
    
    /// Create a properly configured JSON decoder
    private func createJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    /// Create a properly configured JSON encoder
    private func createJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    
    // MARK: - Network Status
    
    /// Check if network is available for API calls
    func isNetworkAvailable() -> Bool {
        return networkMonitor.isConnected
    }
    
    /// Handle network unavailable errors
    func handleNetworkError<T>() -> AnyPublisher<T, Error> {
        logger.warning("Network connection not available")
        return Fail(error: URLError(.notConnectedToInternet)).eraseToAnyPublisher()
    }
}

// MARK: - Convenience Extensions

extension AuthenticationManager {
    /// Execute an authenticated API call with automatic token refresh
    func authenticatedRequest<T: Codable>(
        url: URL,
        method: String,
        body: Data? = nil,
        responseType: T.Type
    ) -> AnyPublisher<T, Error> {
        
        // Check authentication
        guard isAuthenticated else {
            return handleAuthenticationError()
        }
        
        // Check network
        guard isNetworkAvailable() else {
            return handleNetworkError()
        }
        
        // Create authenticated request
        var request = createAuthenticatedRequest(url: url, method: method)
        if let body = body {
            request.httpBody = body
        }
        
        // Execute request with automatic token refresh
        let publisher = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                // Log response status for debugging
                if let httpResponse = response as? HTTPURLResponse {
                    self.logger.debug("Received response with status code: \(httpResponse.statusCode)")
                    
                    // Convert 401 status to proper error
                    if httpResponse.statusCode == 401 {
                        self.logger.warning("Received 401 Unauthorized response")
                        throw URLError(.userAuthenticationRequired)
                    }
                    
                    if httpResponse.statusCode >= 400 {
                        self.logger.error("Server error: \(httpResponse.statusCode)")
                    }
                }
                return data
            }
            .decode(type: responseType, decoder: createJSONDecoder())
            .eraseToAnyPublisher()
        
        return withAutoTokenRefresh(originalPublisher: publisher)
    }
}
