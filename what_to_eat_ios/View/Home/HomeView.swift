//
//  HomeView.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 2/8/25.
//

import SwiftUI
import Kingfisher

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var searchOpened: Bool = false
    @State private var searchText: String = ""
    @Binding var selectedTab: Int
    
    // Add observer for language changes
    @ObservedObject private var localization = LocalizationObserver()
    
    private func buildDishCards() -> [AnyView] {
        return homeViewModel.featuredDishes.map { dish in
            AnyView(
                HomeDishCard(dish: dish, height: 250)
            )
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground),
                        colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HomeSearchBar(text: $searchText, onSearchChanged: { newText in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            searchOpened = !newText.isEmpty
                        }
                        
                        // Call search function in view model when text changes
                        if !newText.isEmpty {
                            homeViewModel.searchDishes(keyword: newText)
                        }
                    })
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    
                    HomeSearchResult(isOpen: searchOpened)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            // Featured dishes carousel
                            VStack(alignment: .leading) {
                                LocalizedText("featured_dishes")
                                    .font(.headline)
                                    .padding(.leading)
                                
                                if homeViewModel.featuredDishes.isEmpty && !homeViewModel.isLoading {
                                    LocalizedText("no_results")
                                        .foregroundColor(.gray)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    Carousel(buildDishCards(), spacing: 16, itemWidth: UIScreen.main.bounds.width - 32, height: 250)
                                }
                            }
                            
                            HomeGameSection()
                            
                            HomeBanner(selectedTab: $selectedTab)
                            
                            // Recent dishes section
                            RecentDishes(dishes: homeViewModel.recentDishes)
                            
                            HomeContactSection().padding(.top)
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        homeViewModel.loadRandomDishes(limit: 10)
                    }
                }
                
                // Loading indicator
                if homeViewModel.isLoading {
                    ProgressView {
                        LocalizedText("loading")
                    }
                    .progressViewStyle(CircularProgressViewStyle())
                    .background(Color(.systemBackground).opacity(0.7))
                    .cornerRadius(10)
                    .padding(20)
                }
            }
            .navigationTitle(LocalizationService.shared.localizedString(for: "home_title"))
            .onAppear {
                if homeViewModel.featuredDishes.isEmpty {
                    homeViewModel.loadRandomDishes(limit: 10)
                }
            }
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
}
