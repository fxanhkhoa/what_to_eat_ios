//
//  ContentView.swift
//  what-to-eat-ios
//
//  Created by System on 18/8/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showProfile = false
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "house.fill")
                        LocalizedText("home_tab")
                    }
                    .tag(0)
                
                DishListView()
                    .tabItem {
                        Image(systemName: "fork.knife")
                        LocalizedText("dish_tab")
                    }
                    .tag(1)
                
                IngredientView()
                    .tabItem {
                        Image(systemName: "leaf.fill")
                        LocalizedText("ingredient_tab")
                    }
                    .tag(2)
                
                GameView()
                    .tabItem {
                        Image(systemName: "gamecontroller.fill")
                        LocalizedText("game_tab")
                    }
                    .tag(3)
                
                SettingView()
                    .tabItem {
                        Image(systemName: "gear")
                        LocalizedText("setting_tab")
                    }
                    .tag(4)
            }
            .accentColor(Color("PrimaryColor"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showProfile = true
                    }) {
                        if let user = authViewModel.currentUser, let urlString = user.profileImageURL, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.gray)
                        }
                    }
                    .id(authViewModel.currentUser?.id) // Force toolbar update when user changes
                    .accessibilityLabel(authViewModel.isAuthenticated ? "Profile" : "Login")
                }
            }
            .sheet(isPresented: $showProfile) {
                // Show profile or login view
                if authViewModel.isAuthenticated {
                    // Replace with your profile/account view
                    VStack {
                        if let user = authViewModel.currentUser {
                            if let urlString = user.profileImageURL, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                            }
                            Text(user.name ?? "User")
                                .font(.title2)
                                .padding(.top, 8)
                            Text(user.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Button(action: {
                                authViewModel.signOut()
                                showProfile = false
                            }) {
                                Text(LocalizedStringKey("sign_out"))
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                    }
                    .padding()
                } else {
                    // Replace with your login view if needed
                    LoginView(dismiss: {
                        showProfile = false
                    })
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
