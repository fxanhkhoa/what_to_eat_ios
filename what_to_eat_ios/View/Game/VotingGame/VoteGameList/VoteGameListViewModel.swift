//
//  VoteGameListViewModel.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 20/8/25.
//

import SwiftUI
import Combine

@MainActor
class VoteGameListViewModel: ObservableObject {
    @Published var voteGames: [DishVote] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasMorePages: Bool = false
    @Published var currentPage: Int = 1
    
    // Filter properties
    @Published var searchKeyword: String = ""
    @Published var sortBy: String = "createdAt"
    @Published var sortOrder: String = "desc"
    
    private let dishVoteService = DishVoteService()
    private var cancellables = Set<AnyCancellable>()
    private let pageSize = 20
    private var searchDebounceTimer: Timer?
    
    // MARK: - Computed Properties
    
    var hasActiveFilters: Bool {
        !searchKeyword.isEmpty || sortBy != "createdAt" || sortOrder != "desc"
    }
    
    // MARK: - Public Methods
    
    func loadVoteGames() {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage = 1
        errorMessage = nil
        
        let filter = DishVoteFilter(
            keyword: searchKeyword.isEmpty ? nil : searchKeyword,
            page: currentPage,
            limit: pageSize,
            sortBy: sortBy,
            sortOrder: sortOrder
        )
        
        dishVoteService.findAll(filter: filter)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.voteGames = response.data
                    self?.hasMorePages = response.count >= self?.pageSize ?? 20
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshVoteGames() async {
        currentPage = 1
        loadVoteGames()
    }
    
    func loadMoreVoteGames() {
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        currentPage += 1
        
        let filter = DishVoteFilter(
            keyword: searchKeyword.isEmpty ? nil : searchKeyword,
            page: currentPage,
            limit: pageSize,
            sortBy: sortBy,
            sortOrder: sortOrder
        )
        
        dishVoteService.findAll(filter: filter)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.currentPage -= 1 // Rollback page increment on error
                    }
                },
                receiveValue: { [weak self] response in
                    self?.voteGames.append(contentsOf: response.data)
                    self?.hasMorePages = response.data.count >= self?.pageSize ?? 20
                }
            )
            .store(in: &cancellables)
    }
    
    func updateSearchKeyword(_ keyword: String) {
        searchKeyword = keyword
        
        // Debounce search to avoid too many API calls
        searchDebounceTimer?.invalidate()
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.loadVoteGames()
        }
    }
    
    func applySorting(sortBy: String, sortOrder: String) {
        self.sortBy = sortBy
        self.sortOrder = sortOrder
        loadVoteGames()
    }
    
    func clearFilters() {
        searchKeyword = ""
        sortBy = "createdAt"
        sortOrder = "desc"
        loadVoteGames()
    }
}
