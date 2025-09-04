//
//  DishFilterView.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 14/8/25.
//

import SwiftUI

struct DishFilterView: View {
    @Binding var filters: DishFilters
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempFilters: DishFilters
    let localization = LocalizationService.shared
    
    init(filters: Binding<DishFilters>, onApply: @escaping () -> Void) {
        self._filters = filters
        self.onApply = onApply
        self._tempFilters = State(initialValue: filters.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Time Filters Section
                Section(localization.localizedString(for: "Cooking Time")) {
                    timeFilterSection
                }
                
                // Difficulty Section
                Section(localization.localizedString(for: "Difficulty Level")) {
                    difficultySection
                }
                
                // Meal Categories Section
                Section(localization.localizedString(for: "Meal Categories")) {
                    mealCategoriesSection
                }
                
                // Ingredient Categories Section
                Section(localization.localizedString(for: "Ingredient Categories")) {
                    ingredientCategoriesSection
                }
                
                // Tags Section
                Section(localization.localizedString(for: "Tags")) {
                    tagsSection
                }
            }
            .navigationTitle(localization.localizedString(for: "Filter Dishes"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.localizedString(for: "Cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.localizedString(for: "Apply")) {
                        filters = tempFilters
                        onApply()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button(localization.localizedString(for: "Clear All Filters")) {
                        tempFilters = DishFilters()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private var timeFilterSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Preparation Time
            VStack(alignment: .leading, spacing: 8) {
                Text(localization.localizedString(for:"Preparation Time (minutes)"))
                    .font(.subheadline)
                    .fontWeight(.medium)
                VStack(alignment: .leading, spacing: 8) {
                    LocalizedText("\(localization.localizedString(for:"Min")): \(Int(tempFilters.preparationTimeFrom ?? 0))")
                    Slider(value: Binding(
                        get: { Double(tempFilters.preparationTimeFrom ?? 0) },
                        set: { tempFilters.preparationTimeFrom = Int($0) }
                    ), in: 0...240, step: 1)
                    .accentColor(.accent)
                }
                VStack(alignment: .leading, spacing: 8){
                    Text("\(localization.localizedString(for:"Max")): \(Int(tempFilters.preparationTimeTo ?? 240))")
                    Slider(value: Binding(
                        get: { Double(tempFilters.preparationTimeTo ?? 240) },
                        set: { tempFilters.preparationTimeTo = Int($0) }
                    ), in: Double(tempFilters.preparationTimeFrom ?? 0)...240, step: 1)
                    .accentColor(.accentColor)
                }
            }
            // Cooking Time
            VStack(alignment: .leading, spacing: 8) {
                Text(localization.localizedString(for:"Cooking Time (minutes)"))
                    .font(.subheadline)
                    .fontWeight(.medium)
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(localization.localizedString(for:"Min")): \(Int(tempFilters.cookingTimeFrom ?? 0))")
                    Slider(value: Binding(
                        get: { Double(tempFilters.cookingTimeFrom ?? 0) },
                        set: { tempFilters.cookingTimeFrom = Int($0) }
                    ), in: 0...240, step: 1)
                    .accentColor(.green)
                }
                VStack(alignment: .leading, spacing: 8){
                    Text("\(localization.localizedString(for:"Max")): \(Int(tempFilters.cookingTimeTo ?? 240))")
                    Slider(value: Binding(
                        get: { Double(tempFilters.cookingTimeTo ?? 240) },
                        set: { tempFilters.cookingTimeTo = Int($0) }
                    ), in: Double(tempFilters.cookingTimeFrom ?? 0)...240, step: 1)
                    .accentColor(.green)
                }
            }
        }
    }
    
    private var difficultySection: some View {
        HStack(spacing: 12) {
            ForEach(DifficultyLevel.allCases) { level in
                let isSelected = tempFilters.difficultLevels.contains(level.rawValue)
                Button(action: {
                    if isSelected {
                        tempFilters.difficultLevels.removeAll { $0 == level.rawValue }
                    } else {
                        tempFilters.difficultLevels.append(level.rawValue)
                    }
                }) {
                    HStack {
                        Image(level.svgIconName)
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text(localization.localizedString(for: level.localizationKey))
                            .font(.caption)
                    }.padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(isSelected ? level.color : Color.clear)
                        .foregroundColor(isSelected ? .white : .primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(level.color, lineWidth: 1)
                        )
                        .cornerRadius(16)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var mealCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(MealCategory.allCases) { category in
                HStack {
                    Button(action: {
                        if tempFilters.mealCategories.contains(category.rawValue) {
                            tempFilters.mealCategories.removeAll { $0 == category.rawValue }
                        } else {
                            tempFilters.mealCategories.append(category.rawValue)
                        }
                    }) {
                        HStack {
                            Image(systemName: tempFilters.mealCategories.contains(category.rawValue) ? "checkmark.square.fill" : "square")
                                .foregroundColor(tempFilters.mealCategories.contains(category.rawValue) ? .blue : .gray)
                            

                            Text(localization.localizedString(for: category.localizationKey))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var ingredientCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(IngredientCategory.allCases) { category in
                HStack {
                    Button(action: {
                        if tempFilters.ingredientCategories.contains(category.rawValue) {
                            tempFilters.ingredientCategories.removeAll { $0 == category.rawValue }
                        } else {
                            tempFilters.ingredientCategories.append(category.rawValue)
                        }
                    }) {
                        HStack {
                            Image(systemName: tempFilters.ingredientCategories.contains(category.rawValue) ? "checkmark.square.fill" : "square")
                                .foregroundColor(tempFilters.ingredientCategories.contains(category.rawValue) ? .blue : .gray)
                            
                            Image(systemName: category.iconName)
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(.accent)
                            
                            Text(localization.localizedString(for: category.localizationKey))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.localizedString(for: "Add custom tags"))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TagInputView(tags: $tempFilters.tags)
            
            if !tempFilters.tags.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                    ForEach(tempFilters.tags, id: \.self) { tag in
                        HStack(spacing: 4) {
                            Text("#\(tag)")
                                .font(.caption)
                                .foregroundColor(.blue)
                            
                            Button(action: {
                                tempFilters.tags.removeAll(where: { $0 == tag })
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .contentShape(Rectangle())
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}

struct TagInputView: View {
    @Binding var tags: [String]
    @State private var newTag = ""
    
    var body: some View {
        HStack {
            TextField(LocalizationService.shared.localizedString(for: "Enter tag and press return"), text: $newTag)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    addTag()
                }
            
            Button(LocalizationService.shared.localizedString(for: "Add"), action: addTag)
                .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedTag.isEmpty && !tags.contains(trimmedTag) else { return }
        tags.append(trimmedTag)
        newTag = ""
    }
}

#Preview {
    DishFilterView(
        filters: .constant(DishFilters()),
        onApply: {}
    )
}
