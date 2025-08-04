//
//  ThemeManager.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 2/8/25.
//

import SwiftUI

enum Theme: String {
    case light, dark, system
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var selectedTheme: Theme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    // Computed property for isDarkMode to maintain compatibility with existing code
    var isDarkMode: Bool {
        get {
            return selectedTheme == .dark
        }
        set {
            selectedTheme = newValue ? .dark : .light
        }
    }
    
    init() {
        // Load saved theme or use system default
        let savedThemeString = UserDefaults.standard.string(forKey: "selectedTheme") ?? Theme.system.rawValue
        self.selectedTheme = Theme(rawValue: savedThemeString) ?? .system
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
    }
    
    // Supports setting theme to light, dark or system
    func setTheme(_ theme: Theme) {
        self.selectedTheme = theme
    }
}

// Environment key for accessing ThemeManager
struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager()
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}
