//
//  VotingGameCreateViewModel.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 19/8/25.
//

import SwiftUI
import Combine

@MainActor
class VotingGameCreateViewModel: ObservableObject {
    @Published var voteTitle: String = ""
    @Published var voteDescription: String = ""
    @Published var selectedDishes: [DishVoteItem] = []
    @Published var isCreating: Bool = false
    @Published var errorMessage: String?
    @Published var showSuccess: Bool = false
    
    private let dishVoteService = DishVoteService()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var canCreateVote: Bool {
        !voteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedDishes.count >= 2
    }
    
    // MARK: - Methods
    
    func addDish(_ dish: Dish) {
        // Check if dish is already added
        guard !selectedDishes.contains(where: { !$0.isCustom && $0.slug == dish.slug }) else {
            return
        }
        
        let dishVoteItem = DishVoteItem(
            slug: dish.slug,
            customTitle: nil,
            voteUser: [],
            voteAnonymous: [],
            isCustom: false
        )
        
        selectedDishes.append(dishVoteItem)
    }
    
    func addCustomDish(title: String, url: String?) {
        // Check if custom dish with same title is already added
        guard !selectedDishes.contains(where: { $0.isCustom && $0.customTitle == title }) else {
            return
        }
        
        let customDishVoteItem = DishVoteItem(
            slug: url ?? title, // Use URL as slug if provided, otherwise use title
            customTitle: title,
            voteUser: [],
            voteAnonymous: [],
            isCustom: true
        )
        
        selectedDishes.append(customDishVoteItem)
    }
    
    func removeDish(at index: Int) {
        guard index < selectedDishes.count else { return }
        selectedDishes.remove(at: index)
    }
    
    func clearAllDishes() {
        selectedDishes.removeAll()
    }
    
    func createVote() {
        guard canCreateVote else { return }
        
        isCreating = true
        errorMessage = nil
        
        let createDto = CreateDishVoteDto(
            title: voteTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            description: voteDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : voteDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            dishVoteItems: selectedDishes
        )
        
        dishVoteService.create(dto: createDto)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isCreating = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] dishVote in
                    self?.showSuccess = true
                    // Reset form after successful creation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self?.resetForm()
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func resetForm() {
        voteTitle = ""
        voteDescription = ""
        selectedDishes.removeAll()
        showSuccess = false
    }
}
