//
//  ContentView.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 2/8/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var themeManager: ThemeManager
    let localization = LocalizationService.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label(localization.localizedString(for: "home_tab"), systemImage: "house")
                }
                .tag(0)
            
            DishView()
                .tabItem {
                    Label(localization.localizedString(for: "dish_tab"), systemImage: "fork.knife")
                }
                .tag(1)
            
            IngredientView()
                .tabItem {
                    Label(localization.localizedString(for: "ingredient_tab"), systemImage: "carrot")
                }
                .tag(2)
            
            GameView()
                .tabItem {
                    Label(localization.localizedString(for: "game_tab"), systemImage: "gamecontroller")
                }
                .tag(3)
            
            SettingView()
                .tabItem {
                    Label(localization.localizedString(for: "setting_tab"), systemImage: "gear")
                }
                .tag(4)
        }
        .onAppear() {
            let appearence = UITabBarAppearance()
            appearence.configureWithOpaqueBackground()
            UITabBar.appearance().scrollEdgeAppearance = appearence
        }
        .preferredColorScheme(themeManager.selectedTheme.colorScheme)
        .transition(.slide)
        .animation(.easeInOut, value: selectedTab)
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
