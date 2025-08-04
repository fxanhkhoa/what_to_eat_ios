//
//  SearchBar.swift
//  what-to-eat-ios
//
//  Created by Khoa Bui on 2/8/25.
//

import SwiftUI

struct HomeSearchBar: View {
    @Binding var text: String
    var onSearchChanged: ((String) -> Void)? = nil
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search ...", text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: text) { oldValue, newValue in
                    // Call the provided handler when text changes
                    onSearchChanged?(newValue)
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    // Also notify about clearing the search
                    onSearchChanged?("")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    HomeSearchBar(text: .constant(""), onSearchChanged: { text in
        print("Search text changed: \(text)")
    })
}
