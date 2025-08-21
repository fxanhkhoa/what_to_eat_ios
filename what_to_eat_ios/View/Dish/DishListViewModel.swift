//
//  DishListViewModel.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 14/8/25.
//

import Foundation
import Combine
import SwiftUI

class DishListViewModel: ObservableObject {
    @Published var dishes: [Dish] = []
    @Published var isLoading = false
    @Published var filters = DishFilters()
    @Published var currentPage = 1
    @Published var hasMorePages = true
    @Published var errorMessage: String?
    
    private let dishService = DishService()
    private var cancellables = Set<AnyCancellable>()
    private let pageSize = 20
    private var searchDebounceTimer: Timer?
    
    var hasActiveFilters: Bool {
        !filters.isEmpty
    }
    
    var activeFilterChips: [FilterChipData] {
        var chips: [FilterChipData] = []
        
        // Meal categories
        for category in filters.mealCategories {
            chips.append(FilterChipData(
                title: category,
                onRemove: { [weak self] in
                    self?.filters.mealCategories.removeAll { $0 == category }
                    self?.applyFilters()
                }
            ))
        }
        
        // Difficulty levels
        for level in filters.difficultLevels {
            chips.append(FilterChipData(
                title: level.capitalized,
                onRemove: { [weak self] in
                    self?.filters.difficultLevels.removeAll { $0 == level }
                    self?.applyFilters()
                }
            ))
        }
        
        // Tags
        for tag in filters.tags {
            chips.append(FilterChipData(
                title: "#\(tag)",
                onRemove: { [weak self] in
                    self?.filters.tags.removeAll { $0 == tag }
                    self?.applyFilters()
                }
            ))
        }
        
        // Time ranges
        if filters.preparationTimeFrom != nil || filters.preparationTimeTo != nil {
            let fromTime = filters.preparationTimeFrom ?? 0
            let toTime = filters.preparationTimeTo ?? 999
            chips.append(FilterChipData(
                title: "Prep: \(fromTime)-\(toTime)min",
                onRemove: { [weak self] in
                    self?.filters.preparationTimeFrom = nil
                    self?.filters.preparationTimeTo = nil
                    self?.applyFilters()
                }
            ))
        }
        
        if filters.cookingTimeFrom != nil || filters.cookingTimeTo != nil {
            let fromTime = filters.cookingTimeFrom ?? 0
            let toTime = filters.cookingTimeTo ?? 999
            chips.append(FilterChipData(
                title: "Cook: \(fromTime)-\(toTime)min",
                onRemove: { [weak self] in
                    self?.filters.cookingTimeFrom = nil
                    self?.filters.cookingTimeTo = nil
                    self?.applyFilters()
                }
            ))
        }
        
        return chips
    }
    
    func loadDishes(query: QueryDishDto) {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage = 1
        
        dishService.findAll(query: query)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.dishes = response.data
                    // Check if we got a full page - if less than pageSize, assume no more pages
                    self?.hasMorePages = response.data.count >= self?.pageSize ?? 20
                    self?.currentPage = 1
                }
            )
            .store(in: &cancellables)
    }
    
    func loadMoreDishes() {
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        let nextPage = currentPage + 1
        
        let query = createQueryDto(page: nextPage)
        
        dishService.findAll(query: query)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    self.dishes.append(contentsOf: response.data)
                    // Check if we got a full page - if less than pageSize, assume no more pages
                    self.hasMorePages = response.data.count >= self.pageSize
                    self.currentPage = nextPage
                }
            )
            .store(in: &cancellables)
    }
    
    @MainActor
    func refreshDishes() async {
        currentPage = 1
        hasMorePages = true
        
        do {
            let query = createQueryDto()
            let response = try await dishService.findAll(query: query)
                .async()
            
            dishes = response.data
            hasMorePages = response.data.count >= pageSize
            currentPage = 1
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func applyFilters() {
        currentPage = 1
        hasMorePages = true
        let query = createQueryDto()
        loadDishes(query: query)
    }
    
    func clearAllFilters() {
        filters = DishFilters()
        applyFilters()
    }
    
    func updateSearchKeyword(_ keyword: String) {
        searchDebounceTimer?.invalidate()
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.filters.keyword = keyword.isEmpty ? nil : keyword
            self?.applyFilters()
        }
    }
    
    func createQueryDto(page: Int? = nil) -> QueryDishDto {
        return QueryDishDto(
            page: page ?? currentPage,
            limit: pageSize,
            keyword: filters.keyword,
            tags: filters.tags.isEmpty ? nil : filters.tags,
            preparationTimeFrom: filters.preparationTimeFrom,
            preparationTimeTo: filters.preparationTimeTo,
            cookingTimeFrom: filters.cookingTimeFrom,
            cookingTimeTo: filters.cookingTimeTo,
            difficultLevels: filters.difficultLevels.isEmpty ? nil : filters.difficultLevels,
            mealCategories: filters.mealCategories.isEmpty ? nil : filters.mealCategories,
            ingredientCategories: filters.ingredientCategories.isEmpty ? nil : filters.ingredientCategories,
            ingredients: filters.ingredients.isEmpty ? nil : filters.ingredients,
            labels: filters.labels.isEmpty ? nil : filters.labels
        )
    }
}

// MARK: - Supporting Types
struct DishFilters {
    var keyword: String?
    var tags: [String] = []
    var preparationTimeFrom: Int?
    var preparationTimeTo: Int?
    var cookingTimeFrom: Int?
    var cookingTimeTo: Int?
    var difficultLevels: [String] = []
    var mealCategories: [String] = []
    var ingredientCategories: [String] = []
    var ingredients: [String] = []
    var labels: [String] = []
    
    var isEmpty: Bool {
        keyword == nil &&
        tags.isEmpty &&
        preparationTimeFrom == nil &&
        preparationTimeTo == nil &&
        cookingTimeFrom == nil &&
        cookingTimeTo == nil &&
        difficultLevels.isEmpty &&
        mealCategories.isEmpty &&
        ingredientCategories.isEmpty &&
        ingredients.isEmpty &&
        labels.isEmpty
    }
}

struct FilterChipData {
    let title: String
    let onRemove: () -> Void
}

// MARK: - Publisher Extension for async/await
extension Publisher {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = first()
                .sink(
                    receiveCompletion: { result in
                        switch result {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
        }
    }
}
