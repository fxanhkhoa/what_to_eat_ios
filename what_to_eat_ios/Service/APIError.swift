//
//  APIError.swift
//  what_to_eat_ios
//
//  Created by System on 22/8/25.
//

import Foundation

/// Common API errors that can occur during network requests
enum APIError: Error, LocalizedError {
    case emptyResponse
    case invalidResponse
    case serverError(Int)
    case networkUnavailable
    case authenticationRequired
    case decodingError(Error)
    case encodingError(Error)
    case invalidURL
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "The server returned an empty response when data was expected."
        case .invalidResponse:
            return "The server returned an invalid response format."
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .networkUnavailable:
            return "Network connection is not available."
        case .authenticationRequired:
            return "Authentication is required to access this resource."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .invalidURL:
            return "The provided URL is invalid."
        case .unknownError(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .emptyResponse:
            return "This usually indicates the API operation was successful but didn't return the expected data. Check your API documentation."
        case .networkUnavailable:
            return "Please check your internet connection and try again."
        case .authenticationRequired:
            return "Please log in again to continue."
        case .serverError(let statusCode) where statusCode >= 500:
            return "The server is experiencing issues. Please try again later."
        case .serverError(let statusCode) where statusCode >= 400:
            return "There was an issue with your request. Please check your input and try again."
        default:
            return "Please try again. If the problem persists, contact support."
        }
    }
}