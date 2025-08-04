//
//  HomeViewModel.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 3/8/25.
//

import Foundation
import Combine
import OSLog

class HomeViewModel: ObservableObject {
    @Published var featuredDishes: [Dish] = []
    @Published var recentDishes: [Dish] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let dishService = DishService()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: "io.vn.eatwhat", category: "HomeViewModel")
    
    func loadRandomDishes(limit: Int = 10) {
        isLoading = true
        errorMessage = nil
        
        // Create sample data for testing when API isn't available
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
//            createSampleDishes(count: limit)
            return
        }
        #endif
        
        logger.info("Loading \(limit) random dishes")
        
        dishService.findRandom(limit: limit)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.handleError(error: error)
                }
            } receiveValue: { [weak self] dishes in
                guard let self = self else { return }
                self.logger.info("Successfully loaded \(dishes.count) random dishes")
                
                // If we got empty dishes, fall back to sample data
                if dishes.isEmpty {
                    self.errorMessage = "No dishes found"
//                    self.createSampleDishes(count: limit)
                } else {
                    self.featuredDishes = dishes
                    self.recentDishes = Array(dishes.prefix(min(5, dishes.count)))
                }
            }
            .store(in: &cancellables)
    }
    
    func searchDishes(keyword: String) {
        guard !keyword.isEmpty else {
            loadRandomDishes()
            return
        }
        
        isLoading = true
        errorMessage = nil
        logger.info("Searching dishes with keyword: \(keyword)")
        
        let query = QueryDishDto(
            page: 1,
            limit: 10,
            keyword: keyword,
            tags: nil,
            preparationTimeFrom: nil,
            preparationTimeTo: nil,
            cookingTimeFrom: nil,
            cookingTimeTo: nil,
            difficultLevels: nil,
            mealCategories: nil,
            ingredientCategories: nil,
            ingredients: nil,
            labels: nil
        )
        
        dishService.findAll(query: query)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.handleError(error: error)
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.logger.info("Search returned \(response.data.count) results")
                
                self.featuredDishes = response.data
                self.recentDishes = Array(response.data.prefix(min(5, response.data.count)))
            }
            .store(in: &cancellables)
    }
    
    // Helper method to handle errors
    private func handleError(error: Error) {
        logger.error("API Error: \(error.localizedDescription)")
        
        // More user-friendly error messages
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                errorMessage = "No internet connection. Please check your network and try again."
            case .timedOut:
                errorMessage = "Request timed out. Please try again."
            case .cannotFindHost:
                errorMessage = "Cannot connect to the server. Please try again later."
            default:
                errorMessage = "Network error: \(urlError.localizedDescription)"
            }
        } else if let decodingError = error as? DecodingError {
            logger.error("Decoding error: \(decodingError)")
            errorMessage = "Sorry, there was a problem with the data from the server."
            
            // In DEBUG, show more detailed error
            #if DEBUG
            errorMessage = "Data format error: \(decodingError.localizedDescription)"
            #endif
            
            // Fall back to sample data
//            createSampleDishes(count: 10)
        } else {
            errorMessage = "Error: \(error.localizedDescription)"
        }
    }
    
    // Create sample dishes for testing or fallback
    private func createSampleDishes(count: Int) {
        var dishes: [Dish] = []
        let dishNames = ["Pasta Carbonara", "Beef Stir Fry", "Vegetable Curry",
                        "Chicken Salad", "Margherita Pizza", "Thai Green Curry",
                        "Beef Burger", "Caesar Salad", "Sushi Rolls", "Apple Pie"]
        
        let descriptions = ["Creamy pasta with bacon and eggs",
                          "Tender beef with mixed vegetables",
                          "Aromatic curry with coconut milk",
                          "Fresh greens with grilled chicken",
                          "Classic pizza with tomatoes and mozzarella",
                          "Spicy Thai curry with vegetables",
                          "Juicy beef patty with fresh toppings",
                          "Romaine lettuce with Caesar dressing",
                          "Fresh fish with rice and seaweed",
                          "Sweet apple filling with flaky crust"]
        
        for i in 0..<min(count, dishNames.count) {
            let titleLang = [MultiLanguage(lang: "en", data: dishNames[i])]
            let descriptionLang = [MultiLanguage(lang: "en", data: descriptions[i])]
            
            let dish = Dish(
                id: "sample-\(i+1)",
                deleted: false,
                createdAt: Date().ISO8601Format(),
                updatedAt: Date().ISO8601Format(),
                createdBy: nil,
                updatedBy: nil,
                deletedBy: nil,
                deletedAt: nil,
                slug: dishNames[i].lowercased().replacingOccurrences(of: " ", with: "-"),
                title: titleLang,
                shortDescription: descriptionLang,
                content: descriptionLang,
                tags: ["sample"],
                preparationTime: [10, 15, 20, 5, 30, 15, 10, 5, 25, 20][i % 10],
                cookingTime: [20, 25, 30, 0, 15, 30, 15, 0, 0, 40][i % 10],
                difficultLevel: ["easy", "medium", "hard"][i % 3],
                mealCategories: ["lunch", "dinner"],
                ingredientCategories: [],
                thumbnail: nil,
                videos: [],
                ingredients: [],
                relatedDishes: [],
                labels: []
            )
            dishes.append(dish)
        }
        
        self.featuredDishes = dishes
        self.recentDishes = Array(dishes.prefix(min(5, dishes.count)))
        self.isLoading = false
    }
}
