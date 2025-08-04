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
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            DishView()
                .tabItem {
                    Label("Dish", systemImage: "fork.knife")
                }
                .tag(1)
            
            IngredientView()
                .tabItem {
                    Label("Ingredient", systemImage: "carrot")
                }
                .tag(2)
            
            GameView()
                .tabItem {
                    Label("Game", systemImage: "gamecontroller")
                }
                .tag(3)
            
            SettingView()
                .tabItem {
                    Label("Setting", systemImage: "gear")
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
