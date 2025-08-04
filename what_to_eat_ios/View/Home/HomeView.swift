//
//  HomeView.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 2/8/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var searchOpened: Bool = false
    @State private var searchText: String = ""
        
    var body: some View {
        NavigationView {
            ZStack {
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
                    .padding(.top, 10)
                    
                    HomeSearchResult(isOpen: searchOpened)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Featured dishes carousel
                            VStack(alignment: .leading) {
                                Text("Featured Dishes")
                                    .font(.headline)
                                    .padding(.leading)
                                
                                if homeViewModel.featuredDishes.isEmpty && !homeViewModel.isLoading {
                                    Text("No dishes found")
                                        .foregroundColor(.gray)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(homeViewModel.featuredDishes) { dish in
                                                DishCard(dish: dish)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            // Recent dishes section
                            VStack(alignment: .leading) {
                                Text("Recent Dishes")
                                    .font(.headline)
                                    .padding(.leading)
                                
                                if homeViewModel.recentDishes.isEmpty && !homeViewModel.isLoading {
                                    Text("No recent dishes")
                                        .foregroundColor(.gray)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    ForEach(homeViewModel.recentDishes) { dish in
                                        DishRow(dish: dish)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        homeViewModel.loadRandomDishes(limit: 10)
                    }
                }
                
                // Loading overlay
                if homeViewModel.isLoading {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                        )
                }
                
                // Error message
                if let errorMessage = homeViewModel.errorMessage {
                    VStack {
                        Spacer()
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(8)
                            .padding()
                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationTitle("What to Eat")
            .onAppear {
                if homeViewModel.featuredDishes.isEmpty {
                    homeViewModel.loadRandomDishes(limit: 10)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
