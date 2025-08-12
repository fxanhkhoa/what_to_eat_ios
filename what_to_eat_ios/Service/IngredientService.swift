//
//  IngredientService.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 12/8/25.
//

import Foundation
import Combine

class IngredientService {
    private let prefix = "ingredient"
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    
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
    
    // MARK: - Find All Ingredients
    func findAll(dto: QueryIngredientDto) -> AnyPublisher<APIPagination<Ingredient>, Error> {
        var queryItems: [URLQueryItem] = []
        
        if let page = dto.page {
            queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
        }
        if let limit = dto.limit {
            queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        }
        if let keyword = dto.keyword {
            queryItems.append(URLQueryItem(name: "keyword", value: keyword))
        }
        if let categories = dto.ingredientCategory {
            for category in categories {
                queryItems.append(URLQueryItem(name: "ingredientCategory", value: category))
            }
        }
        
        var components = URLComponents(string: "\(APIConstants.baseURL)/\(prefix)")!
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let url = components.url else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(APIConstants.Headers.applicationJSON, forHTTPHeaderField: APIConstants.Headers.contentType)
        request.timeoutInterval = 30.0
        
        return urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: APIPagination<Ingredient>.self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Find Random Ingredients
    func findRandom(limit: Int, ingredientCategories: [String]? = nil) -> AnyPublisher<[Ingredient], Error> {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        if let categories = ingredientCategories, !categories.isEmpty {
            for category in categories {
                queryItems.append(URLQueryItem(name: "ingredientCategory", value: category))
            }
        }
        
        var components = URLComponents(string: "\(APIConstants.baseURL)/\(prefix)/random")!
        components.queryItems = queryItems
        
        guard let url = components.url else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(APIConstants.Headers.applicationJSON, forHTTPHeaderField: APIConstants.Headers.contentType)
        request.timeoutInterval = 30.0
        
        return urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Ingredient].self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Create Ingredient
    func create(dto: CreateIngredientDto) -> AnyPublisher<Ingredient, Error> {
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(APIConstants.Headers.applicationJSON, forHTTPHeaderField: APIConstants.Headers.contentType)
        request.timeoutInterval = 30.0
        
        do {
            let jsonData = try JSONEncoder().encode(dto)
            request.httpBody = jsonData
            
            return urlSession.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: Ingredient.self, decoder: jsonDecoder)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    // MARK: - Update Ingredient
    func update(id: String, dto: UpdateIngredientDto) -> AnyPublisher<Ingredient, Error> {
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)/\(id)") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue(APIConstants.Headers.applicationJSON, forHTTPHeaderField: APIConstants.Headers.contentType)
        request.timeoutInterval = 30.0
        
        do {
            let jsonData = try JSONEncoder().encode(dto)
            request.httpBody = jsonData
            
            return urlSession.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: Ingredient.self, decoder: jsonDecoder)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    // MARK: - Find One Ingredient
    func findOne(id: String) -> AnyPublisher<Ingredient, Error> {
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)/\(id)") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(APIConstants.Headers.applicationJSON, forHTTPHeaderField: APIConstants.Headers.contentType)
        request.timeoutInterval = 30.0
        
        return urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Ingredient.self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Delete Ingredient
    func delete(id: String) -> AnyPublisher<Ingredient, Error> {
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)/\(id)") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue(APIConstants.Headers.applicationJSON, forHTTPHeaderField: APIConstants.Headers.contentType)
        request.timeoutInterval = 30.0
        
        return urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Ingredient.self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Convenience Methods
    
    /// Search ingredients by keyword
    func searchIngredients(keyword: String, page: Int = 1, limit: Int = 20) -> AnyPublisher<APIPagination<Ingredient>, Error> {
        let dto = QueryIngredientDto(
            page: page,
            limit: limit,
            keyword: keyword,
            ingredientCategory: nil
        )
        return findAll(dto: dto)
    }
    
    /// Get ingredients by category
    func getIngredientsByCategory(_ categories: [String], page: Int = 1, limit: Int = 20) -> AnyPublisher<APIPagination<Ingredient>, Error> {
        let dto = QueryIngredientDto(
            page: page,
            limit: limit,
            keyword: nil,
            ingredientCategory: categories
        )
        return findAll(dto: dto)
    }
}
