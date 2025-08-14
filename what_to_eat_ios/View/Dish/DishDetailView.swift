//
//  DishDetailView.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 11/8/25.
//

import SwiftUI
import Kingfisher
import WebKit
import Combine

struct DishDetailView: View {
    let dish: Dish
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    var localization = LocalizationService.shared
    
    @State private var checkedIngredients: Set<String> = []
    @State private var fullIngredients: [String: Ingredient] = [:]
    @State private var isLoadingIngredients = false
    private let ingredientService = IngredientService()
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Hero Image Section
                        dishImageSection
                        
                        VStack(alignment: .leading, spacing: 20) {
                            mealCategoriesSection
                            
                            // Title and Basic Info
                            dishTitleSection
                            
                            // Quick Info Cards
                            quickInfoSection
                            
                            // Description Section
                            if let description = getLocalizedDescription() {
                                descriptionSection(description)
                            }
                            
                            // Content Section (Full recipe content)
                            if let content = getLocalizedContent() {
                                contentSection(content)
                            }
                            
                            // Videos Section
                            if let videos = dish.videos, !videos.isEmpty {
                                videosSection(videos)
                            }
                            // Ingredients Section
                            if !dish.ingredients.isEmpty {
                                ingredientsSection
                            }
                            
                            // Tags Section
                            if !dish.tags.isEmpty {
                                tagsSection
                            }
                            
                            // Categories Section
                            ingredientCategoriesSection
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                                .background(
                                    Circle()
                                        .fill(colorScheme == .dark ? Color.black.opacity(0.6) : Color.white.opacity(0.8))
                                        .frame(width: 32, height: 32)
                                )
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            // Add to favorites functionality
                        }) {
                            Image(systemName: "heart")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.red)
                                .background(
                                    Circle()
                                        .fill(colorScheme == .dark ? Color.black.opacity(0.6) : Color.white.opacity(0.8))
                                        .frame(width: 32, height: 32)
                                )
                        }
                    }
                }
            }
            .navigationBarHidden(false)
        }
    }
    
    // MARK: - View Components
    
    private var dishImageSection: some View {
        ZStack(alignment: .bottomLeading) {
            KFImage(URL(string: dish.thumbnail ?? ""))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .frame(width: UIScreen.main.bounds.width)
                .clipped()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.black.opacity(0.7)
                        ]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                ).cornerRadius(12)
            
            // Dish title overlay on image
            VStack(alignment: .leading, spacing: 8) {
                Text(getLocalizedTitle() ?? "Unknown Dish")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                
                HStack {
                    if let difficulty = dish.difficultLevel {
                        let difficultyLevel = DifficultyLevel.from(difficulty)
                        HStack(spacing: 4) {
                            Image(difficultyLevel.svgIconName)
                                .resizable()
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                            LocalizedText(difficultyLevel.localizationKey)
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(difficultyLevel.color.opacity(0.8))
                        )
                    }
                }
            }
            .padding(20)
        }
    }
    
    private var dishTitleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(getLocalizedTitle() ?? "Unknown Dish")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .mask(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#F3A446"),
                            Color(hex: "#A06235")
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }
    
    private var quickInfoSection: some View {
        HStack(spacing: 16) {
            if let prepTime = dish.preparationTime {
                quickInfoCard(
                    icon: "preparation_time",
                    title: LocalizedText("preparation"),
                    value: "\(prepTime) min"
                )
            }
            
            if let cookTime = dish.cookingTime {
                quickInfoCard(
                    icon: "cooking_time",
                    title: LocalizedText("cooking"),
                    value: "\(cookTime) min"
                )
            }
            
            // Show total ingredients count
            if !dish.ingredients.isEmpty {
                quickInfoCard(
                    icon: "ingredient",
                    title: LocalizedText("ingredients"),
                    value: "\(dish.ingredients.count)"
                )
            }
        }
    }
    
    private func quickInfoCard(icon: String, title: LocalizedText, value: String) -> some View {
        VStack(spacing: 8) {
            Image(icon)
                .resizable()
                .font(.title2)
                .foregroundColor(Color(hex: "#F3A446"))
                .frame(width: 40, height: 40)
            
            title
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
                .shadow(
                    color: colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1),
                    radius: 4,
                    x: -2,
                    y: -2
                )
                .shadow(
                    color: colorScheme == .dark ? Color.black.opacity(0.5) : Color.gray.opacity(0.3),
                    radius: 4,
                    x: 2,
                    y: 2
                )
        )
    }
    
    private func descriptionSection(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            LocalizedText("description")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(nil)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                )
        }
    }
    
    private func contentSection(_ content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            LocalizedText("recipe_content")
                .font(.headline)
                .foregroundColor(.primary)
            
            HTMLWebView(htmlContent: content, colorScheme: colorScheme)
                .frame(minHeight: 400)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                )
        }
    }
    
    private func videosSection(_ videos: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            LocalizedText("videos")
                .font(.headline)
                .foregroundColor(.primary)
            ForEach(videos, id: \.self) { video in
                if let url = URL(string: video), let videoId = extractYouTubeId(from: video) {
                    YouTubeWebView(videoID: videoId)
                        .frame(height: 220)
                        .cornerRadius(12)
                        .padding(.bottom, 8)
                } else {
                    Link(video, destination: URL(string: video)!)
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func extractYouTubeId(from url: String) -> String? {
        // Handles typical YouTube URL formats
        if let regex = try? NSRegularExpression(pattern: "(?:v=|youtu.be/)([A-Za-z0-9_-]{11})", options: .caseInsensitive) {
            let range = NSRange(location: 0, length: url.count)
            if let match = regex.firstMatch(in: url, options: [], range: range), match.numberOfRanges > 1 {
                if let swiftRange = Range(match.range(at: 1), in: url) {
                    return String(url[swiftRange])
                }
            }
        }
        return nil
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            LocalizedText("ingredients")
                .font(.headline)
                .foregroundColor(.primary)
            
            if isLoadingIngredients {
                ProgressView("Loading ingredients...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(dish.ingredients, id: \.ingredientId) { dishIngredient in
                        if let fullIngredient = fullIngredients[dishIngredient.ingredientId] {
                            IngredientRow(
                                dishIngredient: dishIngredient,
                                fullIngredient: fullIngredient,
                                isChecked: checkedIngredients.contains(dishIngredient.ingredientId),
                                onToggle: { isChecked in
                                    if isChecked {
                                        checkedIngredients.insert(dishIngredient.ingredientId)
                                    } else {
                                        checkedIngredients.remove(dishIngredient.ingredientId)
                                    }
                                },
                                colorScheme: colorScheme
                            )
                        } else {
                            // Fallback view while ingredient is loading or failed to load
                            IngredientPlaceholderRow(
                                dishIngredient: dishIngredient,
                                isChecked: checkedIngredients.contains(dishIngredient.ingredientId),
                                onToggle: { isChecked in
                                    if isChecked {
                                        checkedIngredients.insert(dishIngredient.ingredientId)
                                    } else {
                                        checkedIngredients.remove(dishIngredient.ingredientId)
                                    }
                                },
                                colorScheme: colorScheme
                            )
                        }
                    }
                }
            }
        }
        .onAppear {
            loadIngredients()
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            LocalizedText("tags")
                .font(.headline)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    
                    ForEach(Array(dish.mealCategories.enumerated()), id: \.offset) { index, category in
                        Button(action: {
                            // Your action here
                            print("Button tapped!")
                        }) {
                            Text(category)
                                .font(.headline)
                        }.buttonStyle(BorderedButtonStyle())
                    }
                }
            }
        }
    }
    
    private var mealCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !dish.mealCategories.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            
                            ForEach(Array(dish.mealCategories.enumerated()), id: \.offset) { index, category in
                                Button(action: {
                                    // Your action here
                                    print("Button tapped!")
                                }) {
                                    Text(category)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(ColorPalette.colorByIndex(for: index))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var ingredientCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !dish.ingredientCategories.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    LocalizedText("ingredient_categories")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            
                            ForEach(Array(dish.ingredientCategories.enumerated()), id: \.offset) { index, category in
                                Button(action: {
                                    // Your action here
                                    print("Button tapped!")
                                }) {
                                    Text(category)
                                        .font(.headline)
                                        .foregroundStyle(ColorPalette.textColorByIndex(for: index, with: false))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(ColorPalette.colorByIndex(for: index, with: false))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getLocalizedTitle() -> String? {
        return MultiLanguage.getLocalizedData(
            from: dish.title,
            for: localization.currentLanguage.rawValue
        )
    }
    
    private func getLocalizedDescription() -> String? {
        return MultiLanguage.getLocalizedData(
            from: dish.shortDescription,
            for: localization.currentLanguage.rawValue
        )
    }
    
    private func getLocalizedContent() -> String? {
        return MultiLanguage.getLocalizedData(
            from: dish.content,
            for: localization.currentLanguage.rawValue
        )
    }
    
    private func loadIngredients() {
        guard fullIngredients.isEmpty else { return }
        
        isLoadingIngredients = true
        let ingredientIds = dish.ingredients.map { $0.ingredientId }
        
        // Load ingredients concurrently
        let publishers = ingredientIds.map { ingredientId in
            ingredientService.findOne(id: ingredientId)
                .map { ingredient in (ingredientId, ingredient) }
                .replaceError(with: (ingredientId, nil))
        }
        
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { ingredientPairs in
                var loadedIngredients: [String: Ingredient] = [:]
                for (id, ingredient) in ingredientPairs {
                    if let ingredient = ingredient {
                        loadedIngredients[id] = ingredient
                    }
                }
                self.fullIngredients = loadedIngredients
                self.isLoadingIngredients = false
            }
            .store(in: &cancellables)
    }
    
    @State private var cancellables = Set<AnyCancellable>()
}

#Preview {
    DishDetailView(dish: SampleData.sampleDish)
        .environmentObject(ThemeManager())
}

struct HTMLWebView: UIViewRepresentable {
    let htmlContent: String
    let colorScheme: ColorScheme
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let uiColor = UIColor(Color.secondary)
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        let a = Int(alpha * 255)
        
        var textColor = ""
        
        if alpha == 1.0 { // Omit alpha if fully opaque
            textColor = String(format: "#%02X%02X%02X", r, g, b)
        } else {
            textColor = String(format: "#%02X%02X%02X%02X", r, g, b, a)
        }
        
        let htmlString = """
        <html>
        <head>
        <style>
        body {
        font-family: '-apple-system', 'HelveticaNeue', 'Helvetica', 'Arial', sans-serif;
        font-size: 2.75rem;
        line-height: 1.5;
        color: \(colorScheme == .dark ? textColor : "black");
        background-color: \(colorScheme == .dark ? "black" : "white");
        }
        </style>
        </head>
        <body style="margin: 0; padding: 20px;">
        \(htmlContent)
        </body>
        </html>
        """
        
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .accentColor : .secondary)
                .onTapGesture { configuration.isOn.toggle() }
            configuration.label
        }
    }
}

struct IngredientRow: View {
    let dishIngredient: IngredientsInDish
    let fullIngredient: Ingredient
    var isChecked: Bool
    var onToggle: (Bool) -> Void
    var colorScheme: ColorScheme
    
    var localization = LocalizationService.shared
    
    private func getLocalizedTitle() -> String {
        return MultiLanguage.getLocalizedData(
            from: fullIngredient.title,
            for: localization.currentLanguage.rawValue
        ) ?? dishIngredient.slug
    }
    
    var body: some View {
        HStack {
            Toggle(isOn: Binding(
                get: { isChecked },
                set: { onToggle($0) }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        if let imageUrl = fullIngredient.images.first, !imageUrl.isEmpty {
                            KFImage(URL(string: imageUrl))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 24, height: 24)
                                .clipShape(Circle())
                        } else {
                            Image("ingredient")
                                .resizable()
                                .foregroundColor(.green)
                                .frame(width: 24, height: 24)
                        }
                        
                        Text(getLocalizedTitle())
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    Text("\(String(format: "%.1f", dishIngredient.quantity)) \(fullIngredient.measure)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !dishIngredient.note.isEmpty {
                        Text(dishIngredient.note)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
            .toggleStyle(CheckboxToggleStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
        )
    }
}

struct IngredientPlaceholderRow: View {
    let dishIngredient: IngredientsInDish
    var isChecked: Bool
    var onToggle: (Bool) -> Void
    var colorScheme: ColorScheme
    
    var body: some View {
        HStack {
            Toggle(isOn: Binding(
                get: { isChecked },
                set: { onToggle($0) }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image("ingredient")
                            .resizable()
                            .foregroundColor(.green)
                            .frame(width: 24, height: 24)
                        
                        Text(dishIngredient.slug)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    Text("\(String(format: "%.1f", dishIngredient.quantity))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !dishIngredient.note.isEmpty {
                        Text(dishIngredient.note)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
            .toggleStyle(CheckboxToggleStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
        )
    }
}

struct YouTubeWebView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let embedHTML = """
        <html><body style='margin:0;padding:0;'>
        <iframe width='100%' height='100%' src='https://www.youtube.com/embed/\(videoID)?playsinline=1' frameborder='0' allowfullscreen></iframe>
        </body></html>
        """
        uiView.loadHTMLString(embedHTML, baseURL: nil)
    }
}
