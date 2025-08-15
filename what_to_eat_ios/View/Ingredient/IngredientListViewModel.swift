//
//  IngredientListViewModel.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 14/8/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class IngredientListViewModel: ObservableObject {
    @Published var ingredients: [Ingredient] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategories: Set<String> = []
    @Published var hasMorePages = true
    
    private var currentPage = 1
    private var currentKeyword: String?
    private var cancellables = Set<AnyCancellable>()
    private let ingredientService = IngredientService()
    private let itemsPerPage = 20
    
    // MARK: - Public Methods
    
    /// Load initial ingredients
    func loadIngredients() {
        guard !isLoading else { return }
        
        currentPage = 1
        currentKeyword = nil
        ingredients.removeAll()
        
        fetchIngredients()
    }
    
    /// Search ingredients by keyword
    func searchIngredients(keyword: String) {
        guard !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            loadIngredients()
            return
        }
        
        currentPage = 1
        currentKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        ingredients.removeAll()
        
        fetchIngredients()
    }
    
    /// Filter ingredients by category
    func filterByCategory(_ category: IngredientCategory?) {
        currentPage = 1
        currentKeyword = nil
        ingredients.removeAll()
        
        if let category = category {
            selectedCategories = [category.rawValue]
        } else {
            selectedCategories.removeAll()
        }
        
        fetchIngredients()
    }
    
    /// Apply filter with multiple categories
    func applyFilter(categories: Set<String>) {
        currentPage = 1
        currentKeyword = nil
        ingredients.removeAll()
        selectedCategories = categories
        
        fetchIngredients()
    }
    
    /// Load more ingredients for pagination
    func loadMoreIngredients() {
        guard !isLoading && hasMorePages else { return }
        
        currentPage += 1
        fetchIngredients(append: true)
    }
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
    
    /// Refresh ingredients
    func refreshIngredients() {
        currentPage = 1
        ingredients.removeAll()
        fetchIngredients()
    }
    
    // MARK: - Private Methods
    
    private func fetchIngredients(append: Bool = false) {
        isLoading = true
        
        let dto = QueryIngredientDto(
            page: currentPage,
            limit: itemsPerPage,
            keyword: currentKeyword,
            ingredientCategory: selectedCategories.isEmpty ? nil : Array(selectedCategories)
        )
        
        ingredientService.findAll(dto: dto)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure(let _):
//                        self?.handleError(error, append: append)
                        break
                    }
                },
                receiveValue: { [weak self] response in
                    self?.handleIngredientsResponse(response, append: append)
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleIngredientsResponse(_ response: APIPagination<Ingredient>, append: Bool) {
        if append {
            ingredients.append(contentsOf: response.data)
        } else {
            ingredients = response.data
        }
        
        // Update pagination state
        hasMorePages = currentPage * itemsPerPage < response.count
        
        isLoading = false
    }
    
    private func handleError(_ error: Error, append: Bool = false) {
        // Only suppress error popup and clear ingredients for initial load (not search/filter/pagination)
        if currentKeyword == nil && selectedCategories.isEmpty && currentPage == 1 && !append {
            ingredients = []
            // Do not set errorMessage (no popup)
            return
        }
        errorMessage = getErrorMessage(for: error)
        print("IngredientListViewModel Error: \(error)")
    }
    
    private func getErrorMessage(for error: Error) -> String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidURL:
                return "Invalid URL"
            case .noData:
                return "No data received"
            case .decodingError:
                return "Failed to decode response"
            case .serverError(statusCode: let statusCode):
                return "Server error: \(statusCode)"
            case .unknownError:
                return "An unknown error occurred"
            }
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "No internet connection"
            case .timedOut:
                return "Request timed out"
            case .cannotFindHost:
                return "Cannot find server"
            default:
                return "Network error: \(urlError.localizedDescription)"
            }
        }
        
        return "An unexpected error occurred"
    }
}

// MARK: - Convenience Methods
extension IngredientListViewModel {
    /// Get random ingredients
    func loadRandomIngredients(limit: Int = 10, categories: [String]? = nil) {
        isLoading = true
        
        ingredientService.findRandom(limit: limit, ingredientCategories: categories)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] randomIngredients in
                    self?.ingredients = randomIngredients
                    self?.hasMorePages = false // Random ingredients don't support pagination
                }
            )
            .store(in: &cancellables)
    }
    
    /// Check if any filters are active
    var hasActiveFilters: Bool {
        return !selectedCategories.isEmpty || currentKeyword != nil
    }
    
    /// Get active filter description
    var activeFilterDescription: String {
        var descriptions: [String] = []
        
        if let keyword = currentKeyword {
            descriptions.append("Keyword: \(keyword)")
        }
        
        if !selectedCategories.isEmpty {
            descriptions.append("Categories: \(selectedCategories.count)")
        }
        
        return descriptions.joined(separator: ", ")
    }
    
    /// Clear all filters
    func clearAllFilters() {
        currentKeyword = nil
        selectedCategories.removeAll()
        loadIngredients()
    }
}
