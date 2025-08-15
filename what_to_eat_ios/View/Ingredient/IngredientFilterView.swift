//
//  IngredientFilterView.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 14/8/25.
//

import SwiftUI

struct IngredientFilterView: View {
    @Environment(\.dismiss) private var dismiss
    
    let selectedCategories: Set<String>
    let onApplyFilter: (Set<String>) -> Void
    
    @State private var tempSelectedCategories: Set<String>
    
    let localization = LocalizationService.shared
    
    init(selectedCategories: Set<String>, onApplyFilter: @escaping (Set<String>) -> Void) {
        self.selectedCategories = selectedCategories
        self.onApplyFilter = onApplyFilter
        self._tempSelectedCategories = State(initialValue: selectedCategories)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text(localization.localizedString(for: "filter_ingredients"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(localization.localizedString(for: "select_categories_to_filter_ingredients"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Divider()
                
                // Filter Options
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Categories Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(localization.localizedString(for: "ingredient_categories"))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 8) {
                                ForEach(IngredientCategory.allCases) { category in
                                    FilterCategoryRow(
                                        category: category,
                                        isSelected: tempSelectedCategories.contains(category.rawValue),
                                        onToggle: { isSelected in
                                            if isSelected {
                                                tempSelectedCategories.insert(category.rawValue)
                                            } else {
                                                tempSelectedCategories.remove(category.rawValue)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
                
                Divider()
                
                // Bottom Actions
                VStack(spacing: 12) {
                    // Selection Summary
                    if !tempSelectedCategories.isEmpty {
                        Text(String(format: localization.localizedString(for: "categories_selected"), tempSelectedCategories.count))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        // Clear All Button
                        Button(action: {
                            tempSelectedCategories.removeAll()
                        }) {
                            Text(localization.localizedString(for: "clear_all"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.1))
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                        }
                        .disabled(tempSelectedCategories.isEmpty)
                        
                        // Apply Filter Button
                        Button(action: {
                            onApplyFilter(tempSelectedCategories)
                            dismiss()
                        }) {
                            Text(localization.localizedString(for: "apply_filter"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
            }
            .navigationTitle(localization.localizedString(for: "filter_ingredients"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.localizedString(for: "cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.localizedString(for: "reset")) {
                        tempSelectedCategories.removeAll()
                    }
                    .disabled(tempSelectedCategories.isEmpty)
                }
            }
        }
    }
}

// MARK: - Filter Category Row
struct FilterCategoryRow: View {
    let category: IngredientCategory
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    let localization = LocalizationService.shared
    
    var body: some View {
        Button(action: {
            onToggle(!isSelected)
        }) {
            HStack(spacing: 12) {
                // Category Icon
                Image(systemName: category.iconName)
                    .font(.title3)
                    .foregroundColor(category.color)
                    .frame(width: 24, height: 24)
                
                // Category Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(localization.localizedString(for: category.localizationKey))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(category.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .blue : .gray.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? category.color.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? category.color.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    IngredientFilterView(
        selectedCategories: ["PROTEIN_FOODS", "VEGETABLES"],
        onApplyFilter: { categories in
            print("Selected categories: \(categories)")
        }
    )
}
