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
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Appearance")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Theme")
                            .fontWeight(.medium)
                        
                        Picker("Select Theme", selection: $themeManager.selectedTheme) {
                            Label("Light", systemImage: "sun.max.fill")
                                .tag(Theme.light)
                            
                            Label("Dark", systemImage: "moon.fill")
                                .tag(Theme.dark)
                            
                            Label("System", systemImage: "gearshape.fill")
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
                            Text("Dark Mode")
                        }
                    }
                    .tint(AppColors.accent)
                }
                
                // Add Language Section
                Section(header: Text("Language")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Language")
                            .fontWeight(.medium)
                            
                        Picker("Language", selection: $selectedLanguage) {
                            Text("English").tag(Language.english)
                            Text("Tiếng Việt").tag(Language.vietnamese)
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 5)
                        .onChange(of: selectedLanguage) { oldValue, newValue in
                            LocalizationService.shared.setLanguage(newValue)
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
            .navigationTitle("Settings")
            .background(AppColors.primaryBackground)
        }
        .accentColor(AppColors.accent)
    }
}

#Preview {
    SettingView()
        .environmentObject(ThemeManager())
}
