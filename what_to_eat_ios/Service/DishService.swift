//
//  DishService.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 3/8/25.
//

import Foundation
import Combine
import OSLog

class DishService {
    private let jsonDecoder: JSONDecoder
    private let urlSession: URLSession
    private let prefix = "dish"
    private let networkMonitor = NetworkMonitor.shared
    private let logger = Logger(subsystem: "io.vn.eatwhat", category: "DishService")
    
    private var dishCache: [String: Dish] = [:]
    
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
    
    func findAll(query: QueryDishDto) -> AnyPublisher<APIPagination<Dish>, Error> {
        // Check network connection first
        guard networkMonitor.isConnected else {
            return Fail(error: URLError(.notConnectedToInternet)).eraseToAnyPublisher()
        }
        
        // Convert QueryDishDto to URL query parameters
        let queryItems = buildQueryItems(from: query)
        
        // Create URL with query parameters
        var urlComponents = URLComponents(string: "\(APIConstants.baseURL)/\(prefix)")!
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            logger.error("Failed to create URL for findAll request")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        logger.info("Making API request to: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(APIConstants.Headers.applicationJSON, forHTTPHeaderField: APIConstants.Headers.contentType)
        request.timeoutInterval = 30.0
        
        return urlSession.dataTaskPublisher(for: request)
            .map { data, response -> Data in
                // Log response for debugging
                if let httpResponse = response as? HTTPURLResponse {
                    self.logger.info("Received response with status code: \(httpResponse.statusCode)")
                    
                    // Check for server errors
                    if httpResponse.statusCode >= 400 {
                        self.logger.error("Server error: \(httpResponse.statusCode)")
                    }
                }
                return data
            }
            .decode(type: APIPagination<Dish>.self, decoder: jsonDecoder)
            .handleEvents(
                receiveSubscription: { _ in
                    self.logger.info("Starting findAll request")
                },
                receiveOutput: { response in
                    self.logger.info("Received \(response.count) dishes")
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
    
    func findBySlug(slug: String) -> AnyPublisher<Dish, Error> {
        // Check cache first
        if let cachedDish = dishCache[slug] {
            return Just(cachedDish)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        // Check network connection
        guard networkMonitor.isConnected else {
            return Fail(error: URLError(.notConnectedToInternet)).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)/slug/\(slug)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(APIConstants.Headers.applicationJSON, forHTTPHeaderField: APIConstants.Headers.contentType)
        request.timeoutInterval = 30.0
        
        return urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Dish.self, decoder: jsonDecoder)
            .handleEvents(receiveOutput: { [weak self] dish in
                self?.dishCache[slug] = dish
            })
            .eraseToAnyPublisher()
    }
    
    func findRandom(limit: Int, mealCategories: [String]? = nil) -> AnyPublisher<[Dish], Error> {
        guard networkMonitor.isConnected else {
            logger.info("No internet connection, returning network error")
            return Fail(error: URLError(.notConnectedToInternet)).eraseToAnyPublisher()
        }
        
        var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        
        if let categories = mealCategories, !categories.isEmpty {
            queryItems.append(URLQueryItem(name: "mealCategories", value: categories.joined(separator: ",")))
        }
        
        var urlComponents = URLComponents(string: "\(APIConstants.baseURL)/\(prefix)/random")!
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            logger.error("Failed to create URL for findRandom request")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        logger.info("Making findRandom API request to: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(APIConstants.Headers.applicationJSON, forHTTPHeaderField: APIConstants.Headers.contentType)
        request.timeoutInterval = 30.0
        
        return urlSession.dataTaskPublisher(for: request)
            .map { data, response -> Data in
                if let httpResponse = response as? HTTPURLResponse {
                    self.logger.info("Received findRandom response with status code: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode >= 400 {
                        self.logger.error("Server error: \(httpResponse.statusCode)")
                    }
                }
                return data
            }
            .decode(type: [Dish].self, decoder: jsonDecoder)
            .handleEvents(
                receiveOutput: { dishes in
                    self.logger.info("Successfully decoded \(dishes.count) random dishes")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.logger.error("findRandom request failed: \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    func create(dto: CreateDishDto) -> AnyPublisher<Dish, Error> {
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(APIConstants.Headers.applicationJSON, forHTTPHeaderField: APIConstants.Headers.contentType)
        
        do {
            let jsonData = try JSONEncoder().encode(dto)
            request.httpBody = jsonData
            
            return urlSession.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: Dish.self, decoder: jsonDecoder)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func update(id: String, dto: UpdateDishDto) -> AnyPublisher<Dish, Error> {
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)/\(id)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue(APIConstants.Headers.applicationJSON, forHTTPHeaderField: APIConstants.Headers.contentType)
        
        do {
            let jsonData = try JSONEncoder().encode(dto)
            request.httpBody = jsonData
            
            return urlSession.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: Dish.self, decoder: jsonDecoder)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func findOne(id: String) -> AnyPublisher<Dish, Error> {
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)/\(id)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(APIConstants.Headers.applicationJSON, forHTTPHeaderField: APIConstants.Headers.contentType)
        
        return urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Dish.self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
    
    func delete(id: String) -> AnyPublisher<Dish, Error> {
        guard let url = URL(string: "\(APIConstants.baseURL)/\(prefix)/\(id)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue(APIConstants.Headers.applicationJSON, forHTTPHeaderField: APIConstants.Headers.contentType)
        
        return urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Dish.self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
    
    // Helper method to convert QueryDishDto to URLQueryItems
    private func buildQueryItems(from query: QueryDishDto) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        
        // Add pagination parameters
        if let page = query.page {
            queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
        }
        
        if let limit = query.limit {
            queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        }
        
        // Add filtering parameters
        if let keyword = query.keyword {
            queryItems.append(URLQueryItem(name: "keyword", value: keyword))
        }
        
        if let tags = query.tags, !tags.isEmpty {
            queryItems.append(URLQueryItem(name: "tags", value: tags.joined(separator: ",")))
        }
        
        if let preparationTimeFrom = query.preparationTimeFrom {
            queryItems.append(URLQueryItem(name: "preparationTimeFrom", value: "\(preparationTimeFrom)"))
        }
        
        if let preparationTimeTo = query.preparationTimeTo {
            queryItems.append(URLQueryItem(name: "preparationTimeTo", value: "\(preparationTimeTo)"))
        }
        
        if let cookingTimeFrom = query.cookingTimeFrom {
            queryItems.append(URLQueryItem(name: "cookingTimeFrom", value: "\(cookingTimeFrom)"))
        }
        
        if let cookingTimeTo = query.cookingTimeTo {
            queryItems.append(URLQueryItem(name: "cookingTimeTo", value: "\(cookingTimeTo)"))
        }
        
        if let difficultLevels = query.difficultLevels, !difficultLevels.isEmpty {
            queryItems.append(URLQueryItem(name: "difficultLevels", value: difficultLevels.joined(separator: ",")))
        }
        
        if let mealCategories = query.mealCategories, !mealCategories.isEmpty {
            queryItems.append(URLQueryItem(name: "mealCategories", value: mealCategories.joined(separator: ",")))
        }
        
        if let ingredientCategories = query.ingredientCategories, !ingredientCategories.isEmpty {
            queryItems.append(URLQueryItem(name: "ingredientCategories", value: ingredientCategories.joined(separator: ",")))
        }
        
        if let ingredients = query.ingredients, !ingredients.isEmpty {
            queryItems.append(URLQueryItem(name: "ingredients", value: ingredients.joined(separator: ",")))
        }
        
        if let labels = query.labels, !labels.isEmpty {
            queryItems.append(URLQueryItem(name: "labels", value: labels.joined(separator: ",")))
        }
        
        return queryItems
    }
}
