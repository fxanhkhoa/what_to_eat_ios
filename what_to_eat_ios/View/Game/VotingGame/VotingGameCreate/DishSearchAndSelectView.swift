//
//  DishSearchAndSelectView.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 19/8/25.
//

import SwiftUI
import Combine

struct DishSearchAndSelectView: View {
    @ObservedObject var viewModel: VotingGameCreateViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @StateObject private var dishViewModel = DishListViewModel()
    @State private var searchText = ""
    @State private var selectedDishes: Set<String> = []
    var localization = LocalizationService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Dish List
                dishList
                
                // Bottom Action Bar
                bottomActionBar
            }
            .navigationTitle("search_and_add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done") {
                        addSelectedDishes()
                        dismiss()
                    }
                    .disabled(selectedDishes.isEmpty)
                }
            }
        }
        .onAppear {
            loadDishes()
        }
        .onChange(of: searchText) {
            searchDishes()
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("search_dishes", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
        )
        .padding()
    }
    
    // MARK: - Dish List
    private var dishList: some View {
        Group {
            if dishViewModel.isLoading {
                LoadingView(localization: localization)
            } else if dishViewModel.dishes.isEmpty {
                EmptyStateView(
                    localization: localization,
                    title: localization.localizedString(for: "no_dishes_found"),
                    subtitle: localization.localizedString(for: "try_adjusting_search_criteria"),
                    systemImage: "fork.knife",
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(dishViewModel.dishes) { dish in
                            DishSelectableRow(
                                dish: dish,
                                isSelected: selectedDishes.contains(dish.slug),
                                isAlreadyAdded: viewModel.selectedDishes.contains { !$0.isCustom && $0.slug == dish.slug },
                                onToggle: {
                                    toggleDishSelection(dish)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Bottom Action Bar
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(selectedDishes.count) dishes selected")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if !selectedDishes.isEmpty {
                        Text("add_more_dishes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    addSelectedDishes()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("add_dishes")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedDishes.isEmpty ? Color.gray : Color("PrimaryColor"))
                    )
                }
                .disabled(selectedDishes.isEmpty)
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color(.systemBackground) : Color(.systemBackground))
    }
    
    // MARK: - Methods
    
    private func loadDishes() {
        let query = QueryDishDto(
            page: 1,
            limit: 50,
            keyword: nil,
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
        dishViewModel.loadDishes(query: query)
    }
    
    private func searchDishes() {
        let query = QueryDishDto(
            page: 1,
            limit: 50,
            keyword: searchText.isEmpty ? nil : searchText,
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
        dishViewModel.loadDishes(query: query)
    }
    
    private func toggleDishSelection(_ dish: Dish) {
        // Don't allow selection if dish is already added to vote
        guard !viewModel.selectedDishes.contains(where: { !$0.isCustom && $0.slug == dish.slug }) else {
            return
        }
        
        if selectedDishes.contains(dish.slug) {
            selectedDishes.remove(dish.slug)
        } else {
            selectedDishes.insert(dish.slug)
        }
    }
    
    private func addSelectedDishes() {
        for dishSlug in selectedDishes {
            if let dish = dishViewModel.dishes.first(where: { $0.slug == dishSlug }) {
                viewModel.addDish(dish)
            }
        }
        selectedDishes.removeAll()
    }
}

// MARK: - Dish Selectable Row
struct DishSelectableRow: View {
    let dish: Dish
    let isSelected: Bool
    let isAlreadyAdded: Bool
    let onToggle: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Dish Image
                AsyncImage(url: URL(string: dish.thumbnail ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color("PrimaryColor").opacity(0.2))
                        .overlay(
                            Image(systemName: "fork.knife")
                                .foregroundColor(Color("PrimaryColor"))
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Dish Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(dish.getTitle(for: "en") ?? dish.slug)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if let shortDescription = dish.getShortDescription(for: "en") {
                        Text(shortDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        if let prepTime = dish.preparationTime {
                            Label("\(prepTime) mins", systemImage: "clock")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        if let difficulty = dish.difficultLevel {
                            Text(difficulty.capitalized)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color("PrimaryColor").opacity(0.2))
                                .foregroundColor(Color("PrimaryColor"))
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                // Selection Indicator
                if isAlreadyAdded {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("PrimaryColor"))
                        .font(.title3)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                    .shadow(radius: isSelected ? 4 : 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isAlreadyAdded ? Color.green :
                            isSelected ? Color("PrimaryColor") : Color.clear,
                        lineWidth: 2
                    )
            )
            .opacity(isAlreadyAdded ? 0.6 : 1.0)
        }
        .disabled(isAlreadyAdded)
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DishSearchAndSelectView(viewModel: VotingGameCreateViewModel())
}
