//
//  IngredientDetailView.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 14/8/25.
//

import SwiftUI

struct IngredientDetailView: View {
    let ingredient: Ingredient
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImageIndex = 0
    let localization = LocalizationService.shared
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image Gallery
                if !ingredient.images.isEmpty {
                    ImageGalleryView(
                        images: ingredient.images,
                        selectedIndex: $selectedImageIndex
                    )
                    .frame(height: 300)
                }
                // Content
                VStack(alignment: .leading, spacing: 16) {
                    TitleSection(ingredient: ingredient, localization: localization)
                    NutritionSection(ingredient: ingredient, localization: localization)
                    CategoriesSection(ingredient: ingredient, localization: localization)
                    AdditionalDetailsSection(ingredient: ingredient, localization: localization)
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle(ingredient.title.first?.data ?? localization.localizedString(for: "ingredient"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareButton(ingredient: ingredient, localization: localization)
            }
        }
    }
}

// MARK: - Image Gallery
struct ImageGalleryView: View {
    let images: [String]
    @Binding var selectedIndex: Int
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Image
            TabView(selection: $selectedIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, imageUrl in
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(.systemGray))
                            )
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            // Page Indicator
            if images.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<images.count, id: \.self) { index in
                        Circle()
                            .fill(selectedIndex == index ? Color.primary : Color(.systemGray4))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 12)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Title Section
struct TitleSection: View {
    let ingredient: Ingredient
    let localization: LocalizationService
    
    func localizedTitle() -> String {
        return ingredient.title.first(where: { $0.lang == localization.currentLanguage.rawValue })?.data ??
               ingredient.title.first?.data ?? localization.localizedString(for: "unknown_ingredient")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localizedTitle())
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if !ingredient.measure.isEmpty {
                Text("\(localization.localizedString(for: "measure")) \(ingredient.measure)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if ingredient.weight != nil {
                Text("\(localization.localizedString(for: "weight")) \(String(format: "%.1f", ingredient.weight ?? 0))g")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Nutrition Section
struct NutritionSection: View {
    let ingredient: Ingredient
    let localization: LocalizationService
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.localizedString(for: "nutrition_information"))
                .font(.title2)
                .fontWeight(.semibold)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                NutritionCard(
                    title: localization.localizedString(for: "calories"),
                    value: String(format: "%.0f", ingredient.calories ?? 0),
                    unit: localization.localizedString(for: "kcal"),
                    color: .orange
                )
                NutritionCard(
                    title: localization.localizedString(for: "protein"),
                    value: String(format: "%.1f", ingredient.protein ?? 0),
                    unit: localization.localizedString(for: "g"),
                    color: .red
                )
                NutritionCard(
                    title: localization.localizedString(for: "carbohydrates"),
                    value: String(format: "%.1f", ingredient.carbohydrate ?? 0),
                    unit: localization.localizedString(for: "g"),
                    color: .blue
                )
                NutritionCard(
                    title: localization.localizedString(for: "fat"),
                    value: String(format: "%.1f", ingredient.fat ?? 0),
                    unit: localization.localizedString(for: "g"),
                    color: .yellow
                )
                NutritionCard(
                    title: localization.localizedString(for: "cholesterol"),
                    value: String(format: "%.1f", ingredient.cholesterol ?? 0),
                    unit: localization.localizedString(for: "mg"),
                    color: .purple
                )
                NutritionCard(
                    title: localization.localizedString(for: "sodium"),
                    value: String(format: "%.1f", ingredient.sodium ?? 0),
                    unit: localization.localizedString(for: "mg"),
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct NutritionCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: color.opacity(colorScheme == .dark ? 0.1 : 0.2), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Categories Section
struct CategoriesSection: View {
    let ingredient: Ingredient
    let localization: LocalizationService
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if !ingredient.ingredientCategory.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(localization.localizedString(for: "categories"))
                    .font(.title2)
                    .fontWeight(.semibold)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(ingredient.ingredientCategory, id: \.self) { categoryString in
                        CategoryChip(category: IngredientCategory.from(categoryString), localization: localization)
                    }
                }
            }
        }
    }
}

struct CategoryChip: View {
    let category: IngredientCategory
    let localization: LocalizationService
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: category.iconName)
                .font(.caption)
                .foregroundColor(category.color)
            Text(localization.localizedString(for: category.localizationKey))
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(category.color.opacity(colorScheme == .dark ? 0.2 : 0.1))
        .foregroundColor(category.color)
        .cornerRadius(16)
    }
}

// MARK: - Additional Details Section
struct AdditionalDetailsSection: View {
    let ingredient: Ingredient
    let localization: LocalizationService
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.localizedString(for: "additional_information"))
                .font(.title2)
                .fontWeight(.semibold)
            VStack(spacing: 8) {
                DetailRow(title: localization.localizedString(for: "slug"), value: ingredient.slug)
                if let createdAt = ingredient.createdAt {
                    DetailRow(title: localization.localizedString(for: "created"), value: formatDate(createdAt))
                }
                if let updatedAt = ingredient.updatedAt {
                    DetailRow(title: localization.localizedString(for: "updated"), value: formatDate(updatedAt))
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Share Button
struct ShareButton: View {
    let ingredient: Ingredient
    let localization: LocalizationService
    
    var body: some View {
        Button(action: shareIngredient) {
            Image(systemName: "square.and.arrow.up")
        }
    }
    
    private func shareIngredient() {
        let title = ingredient.title.first(where: { $0.lang == localization.currentLanguage.rawValue })?.data ??
                   ingredient.title.first?.data ?? localization.localizedString(for: "ingredient")
        let calories = String(format: "%.0f", ingredient.calories ?? 0)
        let protein = String(format: "%.1f", ingredient.protein ?? 0)
        let carbs = String(format: "%.1f", ingredient.carbohydrate ?? 0)
        let fat = String(format: "%.1f", ingredient.fat ?? 0)
        let shareText = """
        \(title)
        
        \(localization.localizedString(for: "nutrition_per_measure")) \(ingredient.measure):
        • \(localization.localizedString(for: "calories")): \(calories) \(localization.localizedString(for: "kcal"))
        • \(localization.localizedString(for: "protein")): \(protein)\(localization.localizedString(for: "g"))
        • \(localization.localizedString(for: "carbs")): \(carbs)\(localization.localizedString(for: "g"))
        • \(localization.localizedString(for: "fat")): \(fat)\(localization.localizedString(for: "g"))
        """
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

#Preview {
    NavigationView {
        IngredientDetailView(ingredient: Ingredient(
            id: "1",
            deleted: false,
            createdAt: "2024-01-01T00:00:00Z",
            updatedAt: "2024-01-01T00:00:00Z",
            createdBy: nil,
            updatedBy: nil,
            deletedBy: nil,
            deletedAt: nil,
            slug: "sample-ingredient",
            title: [MultiLanguage(lang: "en", data: "Sample Ingredient")],
            measure: "100g",
            calories: 150.0,
            carbohydrate: 30.0,
            fat: 5.0,
            ingredientCategory: ["PROTEIN_FOODS", "VEGETABLES"],
            weight: 100.0,
            protein: 10.0,
            cholesterol: 0.0,
            sodium: 200.0,
            images: ["https://via.placeholder.com/300"]
        ))
    }
}
