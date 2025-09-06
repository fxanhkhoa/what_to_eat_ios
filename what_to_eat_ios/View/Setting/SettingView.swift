//
//  SettingView.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 2/8/25.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @ObservedObject private var localizationObserver = LocalizationObserver()
    @State private var selectedLanguage: Language = LocalizationService.shared.currentLanguage
    
    private let localization = LocalizationService.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(localization.localizedString(for: "appearance"))) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localization.localizedString(for: "theme"))
                            .fontWeight(.medium)
                        
                        Picker(localization.localizedString(for: "select_theme"), selection: $themeManager.selectedTheme) {
                            Label(localization.localizedString(for: "light"), systemImage: "sun.max.fill")
                                .tag(Theme.light)
                            
                            Label(localization.localizedString(for: "dark"), systemImage: "moon.fill")
                                .tag(Theme.dark)
                            
                            Label(localization.localizedString(for: "system"), systemImage: "gearshape.fill")
                                .tag(Theme.system)
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 5)
                    }
                    .padding(.vertical, 5)
                    
                    // For backward compatibility
                    Toggle(isOn: $themeManager.isDarkMode) {
                        HStack {
                            Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(themeManager.isDarkMode ? .purple : .orange)
                            Text(localization.localizedString(for: "dark_mode"))
                        }
                    }
                    .tint(AppColors.accent)
                }
                
                // Add Language Section
                Section(header: Text(localization.localizedString(for: "language"))) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localization.localizedString(for: "select_language"))
                            .fontWeight(.medium)
                            
                        Picker(localization.localizedString(for: "language"), selection: $selectedLanguage) {
                            Text(localization.localizedString(for: "english")).tag(Language.english)
                            Text(localization.localizedString(for: "vietnamese")).tag(Language.vietnamese)
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 5)
                        .onChange(of: selectedLanguage) { oldValue, newValue in
                            LocalizationService.shared.setLanguage(newValue)
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                Section(header: Text(localization.localizedString(for: "about"))) {
                    HStack {
                        Text(localization.localizedString(for: "version"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
            .navigationTitle(localization.localizedString(for: "settings"))
            .background(AppColors.primaryBackground)
        }
        .accentColor(AppColors.accent)
    }
}

#Preview {
    SettingView()
        .environmentObject(ThemeManager())
}
