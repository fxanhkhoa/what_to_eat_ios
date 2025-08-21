import SwiftUI

struct WheelDishPickerView: View {
    @Binding var selectedDishes: [Dish]
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = DishListViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var searchText = ""
    let localization = LocalizationService.shared
    
    private let maxDishes = 7
    
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
                    // Selected dishes header
                    selectedDishesHeader
                    
                    // Search header
                    searchHeader
                    
                    // Available dishes grid
                    availableDishesGrid
                }
            }
            .navigationTitle(localization.localizedString(for: "pick_dishes_for_wheel"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.localizedString(for: "cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.localizedString(for: "done")) {
                        dismiss()
                    }
                    .disabled(selectedDishes.isEmpty)
                }
            }
            .onAppear {
                let query = viewModel.createQueryDto()
                viewModel.loadDishes(query: query)
            }
            .onChange(of: searchText) { _, newValue in
                viewModel.updateSearchKeyword(newValue)
            }
        }
    }
    
    private var selectedDishesHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text(localization.localizedString(for: "selected_dishes"))
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(selectedDishes.count)/\(maxDishes)")
                    .font(.subheadline)
                    .foregroundColor(selectedDishes.count >= maxDishes ? .red : .secondary)
            }
            
            if selectedDishes.isEmpty {
                Text(localization.localizedString(for: "no_dishes_selected"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(selectedDishes) { dish in
                            SelectedDishChip(
                                dish: dish,
                                onRemove: {
                                    removeFromSelection(dish)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    private var searchHeader: some View {
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
    
    private var availableDishesGrid: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.dishes.isEmpty {
                LoadingView.forDishes(localization: localization)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.dishes.isEmpty {
                EmptyStateView.forDishes(localization: localization)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.dishes) { dish in
                        SelectableDishCard(
                            dish: dish,
                            isSelected: isSelected(dish),
                            canSelect: canSelectMore(),
                            onTap: {
                                toggleSelection(dish)
                            }
                        )
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
            }
        }
        .refreshable {
            await viewModel.refreshDishes()
        }
    }
    
    // MARK: - Helper Methods
    
    private func isSelected(_ dish: Dish) -> Bool {
        selectedDishes.contains { $0.id == dish.id }
    }
    
    private func canSelectMore() -> Bool {
        selectedDishes.count < maxDishes
    }
    
    private func toggleSelection(_ dish: Dish) {
        if isSelected(dish) {
            removeFromSelection(dish)
        } else if canSelectMore() {
            selectedDishes.append(dish)
        }
    }
    
    private func removeFromSelection(_ dish: Dish) {
        selectedDishes.removeAll { $0.id == dish.id }
    }
}

// MARK: - Selected Dish Chip
struct SelectedDishChip: View {
    let dish: Dish
    let onRemove: () -> Void
    let localization = LocalizationService.shared
    
    var body: some View {
        HStack(spacing: 8) {
            AsyncImage(url: URL(string: dish.thumbnail ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "fork.knife")
                            .foregroundColor(.gray)
                            .font(.caption)
                    )
            }
            .frame(width: 30, height: 30)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Text(getLocalizedTitle(for: dish))
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("PrimaryColor").opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("PrimaryColor"), lineWidth: 1)
                )
        )
    }
    
    private func getLocalizedTitle(for dish: Dish) -> String {
        return MultiLanguage.getLocalizedData(
            from: dish.title,
            for: localization.currentLanguage.rawValue
        ) ?? dish.slug
    }
}

// MARK: - Selectable Dish Card
struct SelectableDishCard: View {
    let dish: Dish
    let isSelected: Bool
    let canSelect: Bool
    let onTap: () -> Void
    let localization = LocalizationService.shared
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    AsyncImage(url: URL(string: dish.thumbnail ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "fork.knife")
                                    .foregroundColor(.gray)
                                    .font(.title2)
                            )
                    }
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Selection overlay
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("PrimaryColor").opacity(0.8))
                            .overlay(
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            )
                    } else if !canSelect {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.5))
                            .overlay(
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            )
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(getLocalizedTitle(for: dish))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 40) // Fixed height for title
                    
                    if let shortDescription = getLocalizedDescription(for: dish) {
                        Text(shortDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 28) // Fixed height for description
                    } else {
                        Spacer()
                            .frame(height: 28) // Same height when no description
                    }
                    
                    HStack {
                        if let prepTime = dish.preparationTime {
                            Label("\(prepTime) \(localization.localizedString(for: "mins"))",
                                  systemImage: "clock")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if let difficulty = dish.difficultLevel {
                            Text(localization.localizedString(for: "difficulty_\(difficulty.lowercased())"))
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color("PrimaryColor").opacity(0.2))
                                .foregroundColor(Color("PrimaryColor"))
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 20) // Fixed height for bottom row
                }
            }
            .frame(height: 220) // Fixed total card height
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                    .shadow(
                        color: isSelected ? Color("PrimaryColor").opacity(0.3) : Color.black.opacity(0.1),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color("PrimaryColor") : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isSelected ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!canSelect && !isSelected)
    }
    
    private func getLocalizedTitle(for dish: Dish) -> String {
        return MultiLanguage.getLocalizedData(
            from: dish.title,
            for: localization.currentLanguage.rawValue
        ) ?? dish.slug
    }
    
    private func getLocalizedDescription(for dish: Dish) -> String? {
        return MultiLanguage.getLocalizedData(
            from: dish.shortDescription,
            for: localization.currentLanguage.rawValue
        )
    }
}

#Preview {
    WheelDishPickerView(selectedDishes: .constant([]))
}
