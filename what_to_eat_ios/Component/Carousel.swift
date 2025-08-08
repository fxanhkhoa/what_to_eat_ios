//
//  Carousel.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 4/8/25.
//

import SwiftUI

struct Carousel<Content: View>: View {
    let items: [Content]
    let spacing: CGFloat
    let itemWidth: CGFloat
    let height: CGFloat
    
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    
    init(_ items: [Content], spacing: CGFloat = 16, itemWidth: CGFloat = 300, height: CGFloat = 200) {
        self.items = items
        self.spacing = spacing
        self.itemWidth = itemWidth
        self.height = height
    }
    
    var body: some View {
        VStack {
            if items.isEmpty {
                Text("No items to display")
                    .frame(height: height)
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(0..<items.count, id: \.self) { index in
                        items[index]
                            .frame(width: itemWidth)
                            .padding(.horizontal, spacing)
                            .tag(index)
                    }
                }
                .frame(height: height)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentIndex)
                                
                // Custom indicators
                HStack(spacing: 8) {
                    ForEach(0..<items.count, id: \.self) { index in
                        Circle()
                            .fill(currentIndex == index ? Color.primary : Color.gray.opacity(0.5))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentIndex == index ? 1.2 : 1.0)
                            .animation(.spring(), value: currentIndex)
                            .onTapGesture {
                                withAnimation {
                                    currentIndex = index
                                }
                            }
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    // Function to handle wrapping indices for looping behavior
    private func wrappedIndex(_ index: Int) -> Int {
        if items.isEmpty {
            return 0
        }
        
        // Handle wrapping at both ends
        if index < 0 {
            return items.count - 1
        } else if index >= items.count {
            return 0
        } else {
            return index
        }
    }
}

struct Carousel_Previews: PreviewProvider {
    static var previews: some View {
        Carousel([
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue)
                .overlay(Text("Item 1").foregroundColor(.white)),
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.green)
                .overlay(Text("Item 2").foregroundColor(.white)),
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.red)
                .overlay(Text("Item 3").foregroundColor(.white))
        ])
    }
}
