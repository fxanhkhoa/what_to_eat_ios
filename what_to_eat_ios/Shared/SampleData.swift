//
//  SampleData.swift
//  what_to_eat_ios
//
//  Created by GitHub Copilot on 7/8/25.
//

import Foundation

struct SampleData {
    
    // Sample dish data for previews
    static let sampleDish = Dish(
        id: "sample-123",
        deleted: false,
        createdAt: "2025-07-01T12:00:00Z",
        updatedAt: "2025-07-05T15:30:00Z",
        slug: "banh-mi-vietnam",
        title: [
            MultiLanguage(lang: "en", data: "Vietnamese Banh Mi"),
            MultiLanguage(lang: "vi", data: "Bánh Mì Việt Nam")
        ],
        shortDescription: [
            MultiLanguage(lang: "en", data: "Delicious Vietnamese sandwich with grilled meat and fresh herbs"),
            MultiLanguage(lang: "vi", data: "Bánh mì thịt nướng thơm ngon với rau thơm")
        ],
        content: [
            MultiLanguage(lang: "en", data: "The Vietnamese banh mi is a fusion of French and Vietnamese cuisine, featuring a crispy baguette filled with savory ingredients."),
            MultiLanguage(lang: "vi", data: "Bánh mì Việt Nam là sự kết hợp giữa ẩm thực Pháp và Việt Nam, với bánh mì giòn bên ngoài và nhân thơm ngon bên trong.")
        ],
        tags: ["sandwich", "vietnamese", "street-food"],
        preparationTime: 15,
        cookingTime: 20,
        difficultLevel: "EASY",
        mealCategories: ["lunch", "breakfast"],
        ingredientCategories: ["bread", "meat", "vegetable"],
        thumbnail: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1160&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        videos: ["https://www.youtube.com/watch?v=GKS6_v3NSko"],
        ingredients: [
            IngredientsInDish(quantity: 1, slug: "baguette", note: "french bread", ingredientId: "bread-123"),
            IngredientsInDish(quantity: 100, slug: "pork", note: "grilled", ingredientId: "pork-123"),
            IngredientsInDish(quantity: 30, slug: "carrot", note: "pickled", ingredientId: "carrot-123"),
            IngredientsInDish(quantity: 20, slug: "cucumber", note: "sliced", ingredientId: "cucumber-123"),
            IngredientsInDish(quantity: 10, slug: "cilantro", note: "fresh", ingredientId: "cilantro-123")
        ],
        relatedDishes: ["pho-ga", "goi-cuon", "bun-cha"],
        labels: ["popular", "favorite"]
    )
    
    // Sample dish collection for carousel and list previews
    static let sampleDishes = [
        sampleDish,
        
        // Pho Bo
        Dish(
            id: "sample-456",
            deleted: false,
            createdAt: "2025-06-15T10:20:00Z",
            updatedAt: "2025-07-02T09:15:00Z",
            slug: "pho-bo",
            title: [
                MultiLanguage(lang: "en", data: "Beef Pho Noodle Soup"),
                MultiLanguage(lang: "vi", data: "Phở Bò")
            ],
            shortDescription: [
                MultiLanguage(lang: "en", data: "Traditional Vietnamese beef noodle soup with aromatic broth"),
                MultiLanguage(lang: "vi", data: "Món phở bò truyền thống với nước dùng thơm ngon")
            ],
            content: [
                MultiLanguage(lang: "en", data: "<p>Pho is Vietnam's national dish featuring rice noodles in a flavorful broth with thinly sliced beef.</p> <img src=\"https://images.unsplash.com/photo-1754829953816-6e506536e7cb?q=80&w=1839&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D\" />"),
                MultiLanguage(lang: "vi", data: "<p>Phở là món ăn quốc dân của Việt Nam với bánh phở trong nước dùng thơm ngon và thịt bò thái mỏng.</p> <img src=\"https://images.unsplash.com/photo-1754829953816-6e506536e7cb?q=80&w=1839&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D\" />")
            ],
            tags: ["soup", "vietnamese", "noodles"],
            preparationTime: 30,
            cookingTime: 180,
            difficultLevel: "medium",
            mealCategories: ["lunch", "dinner"],
            ingredientCategories: ["beef", "noodles", "herbs"],
            thumbnail: "https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?q=80&w=1000",
            videos: ["https://example.com/pho-video"],
            ingredients: [
                IngredientsInDish(quantity: 200, slug: "beef-bones", note: "for broth", ingredientId: "beef-bones-123"),
                IngredientsInDish(quantity: 150, slug: "rice-noodles", note: "flat", ingredientId: "noodles-123"),
                IngredientsInDish(quantity: 100, slug: "beef-slices", note: "thinly sliced", ingredientId: "beef-123")
            ],
            relatedDishes: ["bun-bo-hue", "banh-mi-vietnam", "bun-cha"],
            labels: ["traditional", "popular"]
        ),
        
        // Goi Cuon
        Dish(
            id: "sample-789",
            deleted: false,
            createdAt: "2025-05-20T14:30:00Z",
            updatedAt: "2025-06-18T11:45:00Z",
            slug: "goi-cuon",
            title: [
                MultiLanguage(lang: "en", data: "Fresh Spring Rolls"),
                MultiLanguage(lang: "vi", data: "Gỏi Cuốn")
            ],
            shortDescription: [
                MultiLanguage(lang: "en", data: "Refreshing rice paper rolls with shrimp, herbs, and vermicelli"),
                MultiLanguage(lang: "vi", data: "Gỏi cuốn tươi mát với tôm, rau thơm và bún")
            ],
            content: [
                MultiLanguage(lang: "en", data: "Goi Cuon are fresh Vietnamese spring rolls filled with shrimp, pork, herbs, and rice vermicelli, served with peanut dipping sauce."),
                MultiLanguage(lang: "vi", data: "Gỏi cuốn là món ăn Việt Nam với bánh tráng cuốn nhân tôm, thịt heo, rau thơm và bún, ăn kèm với nước chấm đậu phộng.")
            ],
            tags: ["appetizer", "vietnamese", "fresh", "healthy"],
            preparationTime: 25,
            cookingTime: 10,
            difficultLevel: "easy",
            mealCategories: ["appetizer", "lunch"],
            ingredientCategories: ["seafood", "rice-paper", "herbs"],
            thumbnail: "https://images.unsplash.com/photo-1553530979-fbb9e4aee36f?q=80&w=1000",
            videos: ["https://example.com/goi-cuon-video"],
            ingredients: [
                IngredientsInDish(quantity: 8, slug: "rice-paper", note: "sheets", ingredientId: "rice-paper-123"),
                IngredientsInDish(quantity: 16, slug: "shrimp", note: "cooked and halved", ingredientId: "shrimp-123"),
                IngredientsInDish(quantity: 50, slug: "rice-vermicelli", note: "cooked", ingredientId: "vermicelli-123")
            ],
            relatedDishes: ["cha-gio", "banh-mi-vietnam", "pho-bo"],
            labels: ["fresh", "healthy"]
        )
    ]
}
