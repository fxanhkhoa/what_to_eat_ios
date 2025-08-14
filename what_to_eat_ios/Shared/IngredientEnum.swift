//
//  IngredientEnum.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 14/8/25.
//

import SwiftUI

/// Represents ingredient categories throughout the app
enum IngredientCategory: String, Codable, CaseIterable, Identifiable {
    case milkAndDairy = "MILK_AND_DAIRY"
    case grains = "GRAINS"
    case beveragesNonalcoholic = "BEVERAGES_NONALCOHOLIC"
    case proteinFoods = "PROTEIN_FOODS"
    case snacksAndSweets = "SNACKS_AND_SWEETS"
    case alcoholicBeverages = "ALCOHOLIC_BEVERAGES"
    case water = "WATER"
    case fatsAndOils = "FATS_AND_OILS"
    case mixedDishes = "MIXED_DISHES"
    case fruit = "FRUIT"
    case condimentsAndSauces = "CONDIMENTS_AND_SAUCES"
    case sugars = "SUGARS"
    case vegetables = "VEGETABLES"
    case infantFormulaAndBabyFood = "INFANT_FORMULA_AND_BABY_FOOD"
    case other = "OTHER"
    
    var id: String {
        self.rawValue
    }
    
    /// Display name for the ingredient category
    var displayName: String {
        switch self {
        case .milkAndDairy:
            return "Milk and Dairy"
        case .grains:
            return "Grains"
        case .beveragesNonalcoholic:
            return "Non-Alcoholic Beverages"
        case .proteinFoods:
            return "Protein Foods"
        case .snacksAndSweets:
            return "Snacks and Sweets"
        case .alcoholicBeverages:
            return "Alcoholic Beverages"
        case .water:
            return "Water"
        case .fatsAndOils:
            return "Fats and Oils"
        case .mixedDishes:
            return "Mixed Dishes"
        case .fruit:
            return "Fruit"
        case .condimentsAndSauces:
            return "Condiments and Sauces"
        case .sugars:
            return "Sugars"
        case .vegetables:
            return "Vegetables"
        case .infantFormulaAndBabyFood:
            return "Infant Formula and Baby Food"
        case .other:
            return "Other"
        }
    }
    
    /// Localization key for the ingredient category
    var localizationKey: String {
        switch self {
        case .milkAndDairy:
            return "ingredient_category_milk_and_dairy"
        case .grains:
            return "ingredient_category_grains"
        case .beveragesNonalcoholic:
            return "ingredient_category_beverages_nonalcoholic"
        case .proteinFoods:
            return "ingredient_category_protein_foods"
        case .snacksAndSweets:
            return "ingredient_category_snacks_and_sweets"
        case .alcoholicBeverages:
            return "ingredient_category_alcoholic_beverages"
        case .water:
            return "ingredient_category_water"
        case .fatsAndOils:
            return "ingredient_category_fats_and_oils"
        case .mixedDishes:
            return "ingredient_category_mixed_dishes"
        case .fruit:
            return "ingredient_category_fruit"
        case .condimentsAndSauces:
            return "ingredient_category_condiments_and_sauces"
        case .sugars:
            return "ingredient_category_sugars"
        case .vegetables:
            return "ingredient_category_vegetables"
        case .infantFormulaAndBabyFood:
            return "ingredient_category_infant_formula_and_baby_food"
        case .other:
            return "ingredient_category_other"
        }
    }
    
    /// System image name for the ingredient category
    var iconName: String {
        switch self {
        case .milkAndDairy:
            return "drop.fill"
        case .grains:
            return "leaf.fill"
        case .beveragesNonalcoholic:
            return "cup.and.saucer.fill"
        case .proteinFoods:
            return "fish.fill"
        case .snacksAndSweets:
            return "birthday.cake.fill"
        case .alcoholicBeverages:
            return "wineglass.fill"
        case .water:
            return "drop.circle.fill"
        case .fatsAndOils:
            return "circle.fill"
        case .mixedDishes:
            return "fork.knife"
        case .fruit:
            return "apple.logo"
        case .condimentsAndSauces:
            return "drop.triangle.fill"
        case .sugars:
            return "cube.fill"
        case .vegetables:
            return "carrot.fill"
        case .infantFormulaAndBabyFood:
            return "waterbottle.fill"
        case .other:
            return "questionmark.circle.fill"
        }
    }
    
    /// Color associated with the ingredient category
    var color: Color {
        switch self {
        case .milkAndDairy:
            return .blue
        case .grains:
            return .brown
        case .beveragesNonalcoholic:
            return .cyan
        case .proteinFoods:
            return .red
        case .snacksAndSweets:
            return .pink
        case .alcoholicBeverages:
            return .purple
        case .water:
            return .blue
        case .fatsAndOils:
            return .yellow
        case .mixedDishes:
            return .orange
        case .fruit:
            return .green
        case .condimentsAndSauces:
            return .brown
        case .sugars:
            return .white
        case .vegetables:
            return .green
        case .infantFormulaAndBabyFood:
            return .mint
        case .other:
            return .gray
        }
    }
    
    /// Get IngredientCategory from a string, defaulting to .other if invalid
    static func from(_ string: String?) -> IngredientCategory {
        guard let string = string,
              let category = IngredientCategory(rawValue: string.uppercased()) else {
            return .other
        }
        return category
    }
}
