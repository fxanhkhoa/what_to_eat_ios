//
//  HomeSearchResult.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 3/8/25.
//

import SwiftUI

struct HomeSearchResult: View {
    let isOpen: Bool
    
    var body: some View {
        VStack {
            if isOpen {
                Text("Search Results")
                    .font(.headline)
                    .padding(.top)
                
                // Sample results - replace with your actual results
                ForEach(0..<5) { i in
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text("Search result \(i+1)")
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                Spacer()
            }
        }
        .frame(height: isOpen ? 200 : 0)
        .opacity(isOpen ? 1 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOpen)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

struct SearchResultContainer: View {
    @Binding var isOpen: Bool
    
    var body: some View {
        HomeSearchResult(isOpen: isOpen)
    }
}

#Preview {
    VStack {
        Button("Toggle") { /* Preview only */ }
        HomeSearchResult(isOpen: true)
        Spacer()
    }
}
