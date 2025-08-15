//
//  IngredientView.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 2/8/25.
//

import SwiftUI
import Combine

struct IngredientView: View {
    @StateObject private var viewModel = IngredientListViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var showingFilter = false
    @State private var searchText = ""
    @State private var selectedCategory: IngredientCategory? = nil
    let localization = LocalizationService.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground),
                        colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // Search Bar
                    SearchBar(text: $searchText, onSearchButtonClicked: {
                        viewModel.searchIngredients(keyword: searchText)
                    }, localization: localization)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Category Filter
                    CategoryFilterView(selectedCategory: $selectedCategory, onCategoryChanged: { category in
                        viewModel.filterByCategory(category)
                    }, localization: localization)
                    .padding(.horizontal)
                    
                    // Content
                    if viewModel.isLoading && viewModel.ingredients.isEmpty {
                        LoadingView(localization: localization)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.ingredients.isEmpty {
                        EmptyStateView(localization: localization)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        IngredientListContent(
                            ingredients: viewModel.ingredients,
                            isLoading: viewModel.isLoading,
                            hasMorePages: viewModel.hasMorePages,
                            onLoadMore: {
                                viewModel.loadMoreIngredients()
                            },
                            localization: localization,
                            colorScheme: colorScheme
                        )
                    }
                }
                .navigationTitle(localization.localizedString(for: "ingredients_title"))
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingFilter.toggle()
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                }
                .sheet(isPresented: $showingFilter) {
                    IngredientFilterView(
                        selectedCategories: viewModel.selectedCategories,
                        onApplyFilter: { categories in
                            viewModel.applyFilter(categories: categories)
                        }
                    )
                }
                .alert(localization.localizedString(for: "error"), isPresented: .constant(viewModel.errorMessage != nil)) {
                    Button(localization.localizedString(for: "ok")) {
                        viewModel.clearError()
                    }
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }
                .onAppear {
                    if viewModel.ingredients.isEmpty {
                        viewModel.loadIngredients()
                    }
                }
            }
        }
    }
}

// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    let onSearchButtonClicked: () -> Void
    let localization: LocalizationService
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search ...", text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: text) { oldValue, newValue in
                    // Call the provided handler when text changes
                    onSearchButtonClicked()
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    // Also notify about clearing the search
                    onSearchButtonClicked()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    
}

// MARK: - Category Filter View
struct CategoryFilterView: View {
    @Binding var selectedCategory: IngredientCategory?
    let onCategoryChanged: (IngredientCategory?) -> Void
    let localization: LocalizationService
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All button
                CategoryButton(
                    title: localization.localizedString(for: "all"),
                    isSelected: selectedCategory == nil,
                    action: {
                        selectedCategory = nil
                        onCategoryChanged(nil)
                    }
                )
                
                // Category buttons
                ForEach(IngredientCategory.allCases) { category in
                    CategoryButton(
                        title: localization.localizedString(for:category.localizationKey),
                        isSelected: selectedCategory == category,
                        action: {
                            selectedCategory = category
                            onCategoryChanged(category)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color("AccentColor") : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

// MARK: - List Content
struct IngredientListContent: View {
    let ingredients: [Ingredient]
    let isLoading: Bool
    let hasMorePages: Bool
    let onLoadMore: () -> Void
    let localization: LocalizationService
    let colorScheme: ColorScheme
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground),
                    colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            List {
                ForEach(ingredients) { ingredient in
                    NavigationLink(destination: IngredientDetailView(ingredient: ingredient)) {
                        IngredientRowView(ingredient: ingredient, localization: localization)
                    }
                    .onAppear {
                        if ingredient.id == ingredients.last?.id && hasMorePages && !isLoading {
                            onLoadMore()
                        }
                    }
                }
                .listRowBackground(Color.clear)
                
                if isLoading && !ingredients.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
        }
    }
}

// MARK: - Ingredient Row View
struct IngredientRowView: View {
    let ingredient: Ingredient
    let localization: LocalizationService
    
    func localizedTitle() -> String {
        return ingredient.title.first(where: { $0.lang == localization.currentLanguage.rawValue })?.data ??
               ingredient.title.first?.data ?? localization.localizedString(for: "unknown")
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Image
            AsyncImage(url: URL(string: ingredient.images.first ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(localizedTitle())
                    .font(.headline)
                    .lineLimit(2)
                
                // Categories
                if !ingredient.ingredientCategory.isEmpty {
                    Text(ingredient.ingredientCategory.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // Nutrition info
                HStack {
                    NutritionBadge(title: localization.localizedString(for: "cal"), value: ingredient.calories != nil ? "\(Int(ingredient.calories!))" : "-")
                    NutritionBadge(title: localization.localizedString(for: "protein"), value: ingredient.protein != nil ? "\(String(format: "%.1f", ingredient.protein!))g" : "-")
                    NutritionBadge(title: localization.localizedString(for: "carbs"), value: ingredient.carbohydrate != nil ? "\(String(format: "%.1f", ingredient.carbohydrate!))g" : "-")
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct NutritionBadge: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(4)
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let localization: LocalizationService
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text(localization.localizedString(for: "no_ingredients_found"))
                .font(.title2)
                .fontWeight(.medium)
            
            Text(localization.localizedString(for: "try_adjusting_search"))
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Loading View
struct LoadingView: View {
    let localization: LocalizationService
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(localization.localizedString(for: "loading_ingredients"))
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    IngredientView()
}
