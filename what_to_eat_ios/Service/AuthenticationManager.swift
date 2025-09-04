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
    
    // Add a publisher to notify when tokens are cleared
    private let tokensClearedSubject = PassthroughSubject<Void, Never>()
    
    /// Publisher that emits when tokens are cleared
    var tokensClearedPublisher: AnyPublisher<Void, Never> {
        tokensClearedSubject.eraseToAnyPublisher()
    }
    
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
        guard let token = currentToken else { return false }
        
        // Parse JWT and check if it's still valid
        let parsedToken = parseJWT(for: token)
        return parsedToken?.isValid == true && parsedToken?.isExpired == false
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
        
        // Notify subscribers that tokens were cleared
        tokensClearedSubject.send()
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
    
    func parseJWT(for token: String) -> JWTToken? {
        logger.debug("Parsing JWT token")
        
        // Split JWT into its three parts: header.payload.signature
        let segments = token.components(separatedBy: ".")
        guard segments.count == 3 else {
            logger.error("Invalid JWT format: expected 3 segments, got \(segments.count)")
            return nil
        }
        
        let headerSegment = segments[0]
        let payloadSegment = segments[1]
        let signatureSegment = segments[2]
        
        // Decode header
        guard let headerData = base64URLDecode(headerSegment),
              let headerJSON = try? JSONSerialization.jsonObject(with: headerData) as? [String: Any] else {
            logger.error("Failed to decode JWT header")
            return nil
        }
        
        // Decode payload (claims)
        guard let payloadData = base64URLDecode(payloadSegment) else {
            logger.error("Failed to decode JWT payload")
            return nil
        }
        
        // Parse claims
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let claims = try? decoder.decode(JWTClaims.self, from: payloadData) else {
            logger.error("Failed to parse JWT claims")
            return nil
        }
        
        // Validate token
        let isValid = validateJWTStructure(header: headerJSON, claims: claims)
        
        // Check expiration
        let (isExpired, expirationDate) = checkTokenExpiration(claims: claims)
        
        if isExpired {
            logger.warning("JWT token has expired")
        }
        
        let jwtToken = JWTToken(
            header: headerJSON,
            claims: claims,
            signature: signatureSegment,
            isValid: isValid,
            isExpired: isExpired,
            expirationDate: expirationDate
        )
        
        logger.info("JWT parsed successfully - Valid: \(isValid), Expired: \(isExpired)")
        logTokenInfo(token: jwtToken)
        
        return jwtToken
    }
    
    // MARK: - JWT Helper Methods
    
    /// Decode base64URL encoded string
    private func base64URLDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Add padding if needed
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 = base64.padding(toLength: base64.count + 4 - remainder,
                                  withPad: "=",
                                  startingAt: 0)
        }
        
        return Data(base64Encoded: base64)
    }
    
    /// Validate JWT structure and basic claims
    private func validateJWTStructure(header: [String: Any], claims: JWTClaims) -> Bool {
        // Check if header has required algorithm field
        guard let algorithm = header["alg"] as? String, !algorithm.isEmpty else {
            logger.error("JWT header missing or invalid algorithm")
            return false
        }
        
        // Check if token type is JWT
        if let tokenType = header["typ"] as? String, tokenType.uppercased() != "JWT" {
            logger.warning("Token type is not JWT: \(tokenType)")
        }
        
        // Validate required claims
        guard claims.exp != nil else {
            logger.error("JWT missing expiration time (exp)")
            return false
        }
        
        // Validate subject or user identifier (using your custom claims)
        if claims.sub == nil && claims.id == nil {
            logger.warning("JWT missing subject identifier")
        }
        
        // Validate that we have at least email for user identification
        if claims.email == nil {
            logger.warning("JWT missing email claim")
        }
        
        return true
    }
    
    /// Check if token is expired
    private func checkTokenExpiration(claims: JWTClaims) -> (isExpired: Bool, expirationDate: Date?) {
        guard let exp = claims.exp else {
            return (false, nil)
        }
        
        let expirationDate = Date(timeIntervalSince1970: TimeInterval(exp))
        let isExpired = expirationDate < Date()
        
        // Check not before time if present
        if let nbf = claims.nbf {
            let notBeforeDate = Date(timeIntervalSince1970: TimeInterval(nbf))
            if notBeforeDate > Date() {
                logger.warning("JWT is not yet valid (nbf: \(notBeforeDate))")
                return (true, expirationDate)
            }
        }
        
        return (isExpired, expirationDate)
    }
    
    /// Log token information for debugging
    private func logTokenInfo(token: JWTToken) {
        logger.debug("JWT Token Info:")
        logger.debug("- Subject: \(token.claims.sub ?? "N/A")")
        logger.debug("- User ID: \(token.claims.id ?? "N/A")")
        logger.debug("- Email: \(token.claims.email ?? "N/A")")
        logger.debug("- Role Name: \(token.claims.roleName ?? "N/A")")
        logger.debug("- Name: \(token.claims.name ?? "N/A")")
        logger.debug("- Google ID: \(token.claims.googleId ?? "N/A")")
        logger.debug("- Apple ID: \(token.claims.appleId ?? "N/A")")
        logger.debug("- GitHub ID: \(token.claims.githubId ?? "N/A")")
        logger.debug("- Issuer: \(token.claims.iss ?? "N/A")")
        
        if let exp = token.claims.exp {
            let expDate = Date(timeIntervalSince1970: TimeInterval(exp))
            logger.debug("- Expires: \(expDate)")
        }
        
        if let iat = token.claims.iat {
            let issuedDate = Date(timeIntervalSince1970: TimeInterval(iat))
            logger.debug("- Issued: \(issuedDate)")
        }
    }
    
    /// Get user information from current token
    func getCurrentUserInfo() -> JWTClaims? {
        guard let token = currentToken else {
            logger.warning("No current token available")
            return nil
        }
        
        guard let parsedToken = parseJWT(for: token),
              parsedToken.isValid && !parsedToken.isExpired else {
            logger.warning("Current token is invalid or expired")
            return nil
        }
        
        return parsedToken.claims
    }
    
    /// Check if token will expire within specified time interval
    func willTokenExpireSoon(within timeInterval: TimeInterval = 300) -> Bool {
        guard let token = currentToken,
              let parsedToken = parseJWT(for: token),
              let expirationDate = parsedToken.expirationDate else {
            return true // Assume expiry if we can't parse
        }
        
        let warningDate = Date().addingTimeInterval(timeInterval)
        return expirationDate <= warningDate
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
        
        guard let url = URL(string: "\(APIConstants.baseURL)/auth/refresh-token") else {
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
                        throw URLError(.badServerResponse)
                    }
                    
                    // Handle empty response for successful operations
                    if data.isEmpty && (200...299).contains(httpResponse.statusCode) {
                        self.logger.info("Received empty response for successful operation (status: \(httpResponse.statusCode))")
                        // For empty responses, create a minimal JSON object that can be decoded
                        // This is a workaround for APIs that don't return data on successful operations
                        if method == "POST" || method == "PUT" || method == "PATCH" {
                            self.logger.warning("Empty response detected for \(method) operation - API should return created/updated object")
                        }
                        throw URLError(.zeroByteResource) // This will be caught and handled below
                    }
                }
                return data
            }
            .decode(type: responseType, decoder: createJSONDecoder())
            .catch { error -> AnyPublisher<T, Error> in
                // Handle empty response case
                if let urlError = error as? URLError, urlError.code == .zeroByteResource {
                    self.logger.error("API returned empty response - cannot decode \(String(describing: responseType))")
                    return Fail(error: APIError.emptyResponse).eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        return withAutoTokenRefresh(originalPublisher: publisher)
    }
}
