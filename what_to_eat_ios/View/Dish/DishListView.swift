//
//  DishListView.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 14/8/25.
//

import SwiftUI
import Combine

struct DishListView: View {
    @StateObject private var viewModel = DishListViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var showFilters = false
    @State private var searchText = ""
    var localization = LocalizationService.shared
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
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
                    // Search and Filter Header
                    searchAndFilterHeader
                    
                    // Filter chips
                    if viewModel.hasActiveFilters {
                        activeFiltersSection
                    }
                    
                    // Dish Grid
                    dishGridSection
                }
            }
            .navigationTitle(localization.localizedString(for: "dishes"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFilters = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                DishFilterView(
                    filters: $viewModel.filters,
                    onApply: { viewModel.applyFilters() }
                )
            }
            .onAppear {
                viewModel.loadDishes()
            }
            .onChange(of: searchText) {
                viewModel.updateSearchKeyword(searchText)
            }
        }
    }
    
    private var searchAndFilterHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField(localization.localizedString(for: "search_dishes"), text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    private var activeFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.activeFilterChips, id: \.title) { chip in
                    FilterChip(
                        title: chip.title,
                        onRemove: { chip.onRemove() }
                    )
                }
                
                Button(localization.localizedString(for: "clear_all")) {
                    viewModel.clearAllFilters()
                }
                .font(.caption)
                .foregroundColor(.red)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.1))
                .cornerRadius(16)
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 8)
    }
    
    private var dishGridSection: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.dishes) { dish in
                    NavigationLink(destination: DishDetailView(dish: dish)) {
                        DishCard(dish: dish)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onAppear {
                        if dish.id == viewModel.dishes.last?.id {
                            viewModel.loadMoreDishes()
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Loading indicator
            if viewModel.isLoading && !viewModel.dishes.isEmpty {
                ProgressView()
                    .padding()
            }
            
            // Load more trigger
            Color.clear
                .frame(height: 50)
                .onAppear {
                    if !viewModel.isLoading {
                        viewModel.loadMoreDishes()
                    }
                }
        }
        .refreshable {
            await viewModel.refreshDishes()
        }
    }
}

struct FilterChip: View {
    let title: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray5))
        .cornerRadius(16)
    }
}

#Preview {
    DishListView()
}
